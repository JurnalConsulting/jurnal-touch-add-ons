class PaymentMethodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_user

  def index
    @payment_methods = PaymentMethod.where(setting_id: params[:setting_id])
  end

  def new
    if @user.present?
      access_token = JurnalAccessToken.where(user_id: @user.id).last
      @account_data = Jurnal::Account::AccountResponse.new(JSON.parse($jurnal.account_api.get_accounts(access_token.code)))
      
      @payment_methods_data = Jurnal::PaymentMethod::GetPaymentMethodsResponse.new(
                            JSON.parse(
                              $jurnal.payment_method_api.get_payment_methods(access_token.code)))

      @payment_method = PaymentMethod.new
    else
      redirect_to home_dashboard_path
    end
  end

  def create
    if params['payment_method'].present?
      get_token
      @payment_methods = JSON.parse(params['payment_method'], object_class: PaymentMethod)

      JSON.parse(params[:payment_method]).each do |p|
        payment_method = p.merge("setting_id" => params[:setting_id])
        if PaymentMethod.new(payment_method).valid? 
          PaymentMethod.create(payment_method)
        end
      end
    end
  end

  def edit
  end

  def update
    payment_methods = {}
    JSON.parse(params[:payment_method]).each do |p|
      payment = { p["id"] => p.except("id") }
      payment_methods = payment_methods.merge(payment)
    end
    PaymentMethod.update(payment_methods.keys, payment_methods.values)
  end

  def destroy
    @payment_method = PaymentMethod.where(:id => params['delete_ids']).destroy_all
    get_token
    if @payment_method.length == 0
      redirect_to home_dashboard_path(:access_token => @token)
    end
  end

  private
    def payment_method_params
      params.require(:payment_method)
        .permit([:payment_type_id, :payment_account_id, :payment_fee_percentage, :payment_fee_fixed, :payment_fee_account_id, :token, :payment_type_name])
        .merge(:setting_id => params[:setting_id])
    end

    def set_current_user
      @user = current_user
    end

    def get_token
      @token = JurnalAccessToken.where(user_id: @user.id).last.code
    end
end
