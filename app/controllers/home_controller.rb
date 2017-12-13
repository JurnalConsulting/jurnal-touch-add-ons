class HomeController < ApplicationController
  include ApplicationHelper
  before_action :set_current_user

  def dashboard
    if !params["access_token"].present?
      redirect_to root_path
      return
    end

    company_data = Jurnal::Company::ActiveCompanyResponse.new(
                                JSON.parse(
                                  $jurnal.company_api.get_active_company(params["access_token"])))
    
    if company_data.errors.present?
      redirect_to '/401'
      return
    end

    if company_data.id.nil?
      redirect_to root_path
      return
    end

    if @user.nil?
      access_token = JurnalAccessToken.find_or_create_by(code: params["access_token"])
      @user = User.find_or_create_by(id: company_data.id)
      @user.initialize_user(access_token, company_data)
      access_token.user_id = @user.id
      access_token.save!
    elsif @user.id != company_data.id
      sign_out(@user)
      @user = User.find_by_id(company_data.id)
    end

    sign_in(@user)
    @user.update_attribute :company_package, company_data.company_package

    @settings = @user.settings
    @devices = @user.devices
  end

  def index
    @token = params["access_token"]
    user = JurnalAccessToken.where(code: params["access_token"]).first.try(:user)
    if user.present?
      redirect_to home_dashboard_path(access_token: @token)
      return
    end
  end

  private
    def set_current_user
      @user ||= JurnalAccessToken.where(code: params["access_token"]).first.try(:user)
    end
end