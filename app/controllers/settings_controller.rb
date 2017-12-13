class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_user
  before_action :inject_collections, only: [:new, :show, :edit]

  def new
    get_token
    if @user.present?
      @setting_code = generate_random_tokens
    
      while Setting.where(code: @setting_code).exists?
        @setting_code = generate_random_tokens
      end

      @setting = Setting.new({name: "Setting #{@user.settings.count + 1}", code: @setting_code, token: SecureRandom.uuid})
      @payment_method_url = setting_payment_methods_path(0)
    else
      redirect_to home_dashboard_path(:access_token => @token)
    end
  end

  def generate_random_tokens
    length = 10
    characters = ('A'..'Z').to_a + ('0'..'9').to_a
    random_token = SecureRandom.random_bytes(length).each_char.map do |char|
      characters[(char.ord % characters.length)]
    end.join
  end

  def edit
    get_token
    @setting = Setting.find(params[:id])
    @devices = @setting.devices
    @setting_tag_ids = @setting.tag_ids.try(:split, ',').try(:reject, &:empty?).try(:map, &:to_i)
    @payment_methods = @setting.payment_methods
    @payment_methods_json = []
    @payment_methods.each do |p|
      json = {'id': p.id, 'payment_type_id': p.payment_type_id, 'payment_type_name': p.payment_type_name, 'payment_account_id': p.payment_account_id,
        'payment_account_name': p.payment_account_name, 'payment_fee_account_id': p.payment_fee_account_id, 'payment_fee_account_name': p.payment_fee_account_name,
        'payment_fee_percentage': p.payment_fee_percentage, 'payment_fee_fixed': p.payment_fee_fixed, 'setting_id': p.setting_id, 'token': p.token}
      @payment_methods_json.push(json)
    end
    @payment_method_url = setting_payment_method_path(params[:id])
    @device_url = setting_device_path(setting_id: params[:id])
    @edit_payment_method_url = setting_payment_method_path(params[:id])
  end

  def update
    @setting = Setting.find(params[:id])
    get_token
    if @setting.update_attributes(setting_params)
      redirect_to home_dashboard_path(:access_token => @token)
    else
      render 'edit'
    end
  end

  def destroy
    @setting = Setting.find(params[:id])
    get_token
    if @setting.destroy
      redirect_to home_dashboard_path(:access_token => @token)
    end
  end

  def create
    get_token
  	@setting = Setting.new(create_setting_params)
    @setting_tag_ids = ''
  	@setting.user_id = @user.id
  	@setting.save

  	if @setting.save
      payment_method_params.each do |p|
        payment_method_param = p.merge({"setting_id" => @setting.id})
        PaymentMethod.create(payment_method_param) if PaymentMethod.new(payment_method_param).valid?
      end
      respond_to do |format|
        format.html{redirect_to home_dashboard_path(:access_token => @token)}
        format.json {render :json => {:redirect_url =>home_dashboard_path(:access_token => @token)}}
      end
  	else 
  		render 'new'
  	end
  end

   def show
    @setting = Setting.find(params[:id])
    @setting_tag_ids = @setting.tag_ids.try(:split, ',').try(:reject, &:empty?).try(:map, &:to_i)
    @payment_methods = @setting.payment_methods
    @payment_method_url = setting_payment_method_path(params[:id])
  end

  private
  	def create_setting_params
      parse_params = ActionController::Parameters.new(JSON.parse(params[:setting]))
      params = parse_params

      if params[:setting][:tag_ids].present?
        params[:setting][:tag_ids] = params[:setting][:tag_ids].join(', ')
      end

    	params.require(:setting)
        .permit(:name, :code, :warehouse_id, :tag_ids)
  	end

    def setting_params
      if params[:setting][:tag_ids].present?
        params[:setting][:tag_ids] = params[:setting][:tag_ids].join(', ')
      end

      params.require(:setting)
        .permit(:name, :code, :warehouse_id, :tag_ids)
    end

    def payment_method_params
      parse_params = ActionController::Parameters.new(JSON.parse(params[:setting]))
      params = parse_params
      params.require(:setting)
        .permit(payment_method: [:payment_type_id, 
                            :payment_account_id, 
                            :payment_fee_percentage, 
                            :payment_fee_fixed, 
                            :payment_fee_account_id, 
                            :payment_type_name,
                            :id])
        .require(:payment_method)
    end

    def set_current_user
      @user = current_user
    end

    def get_token
      @token = JurnalAccessToken.where(user_id: @user.id).last.code
    end

    def inject_collections
      access_token = JurnalAccessToken.where(user_id: @user.id).last
      @account_data = Jurnal::Account::AccountResponse.new(JSON.parse($jurnal.account_api.get_accounts(access_token.code)))
      @payment_methods_data = Jurnal::PaymentMethod::GetPaymentMethodsResponse.new(
                          JSON.parse(
                            $jurnal.payment_method_api.get_payment_methods(access_token.code)))
      
      @payment_methods_data.payment_methods.each do |x| 
        if x.name.casecmp('cash') != 0 && x.name.casecmp('tunai') != 0
          @payment_method_cash = 'not-found'
        end
      end
      if @payment_method_cash.nil?
        @new_payment_method_data = Jurnal::PaymentMethod::GetPaymentMethodResponse.new(
                                    JSON.parse($jurnal.payment_method_api.create_payment_method(access_token.code,{ name: 'Cash' })))
        @payment_methods_data.payment_methods.push(@new_payment_method_data)
      end
      @payment_method = PaymentMethod.new

      @company_package_enterprise_free = @user.company_package.include?('Enterprise') || @user.company_package.include?('Free')
      @company_package_pro_enterprise_free = @user.company_package.include?('Enterprise') || @user.company_package.include?('Free') ||  @user.company_package.include?('Pro')
      
      if @company_package_enterprise_free == true
        @warehouses = Jurnal::Warehouse::GetWarehousesResponse.new(
                              JSON.parse(
                                $jurnal.warehouse_api.get_warehouses(access_token.code)))
      end

      if @company_package_pro_enterprise_free == true
        @tags = Jurnal::Tags::GetTagsResponse.new(
                              JSON.parse(
                                $jurnal.tags_api.get_tags(access_token.code)))
      end
    end
end
