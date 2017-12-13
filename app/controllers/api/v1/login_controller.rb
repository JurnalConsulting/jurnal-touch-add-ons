class Api::V1::LoginController < Api::V1::ApiController
  before_action :authenticate_user!, only: [:destroy, :refresh]
  def create
    setting = Setting.where(:code => login_params[:code]).first
    device_id = login_params[:device_id]
    device_name = login_params[:device_name]
    device_type = login_params[:device_type]
    device_app_version = login_params[:device_app_version]
    device_os_version = login_params[:device_os_version]
    device_longitude = login_params[:longitude]
    device_latitude = login_params[:latitude]
    if setting.present?
      user = setting.user
      jurnal_token = JurnalAccessToken.where(user_id: user.id).last
      device = Device.where(device_id: device_id, device_name: device_name, setting_id: setting.id).first
      if !device.present?
        #cek quota
        quota = Jurnal::Company::CompanyBillingDetailResponse.new(
                                JSON.parse(
                                  $jurnal.company_api.billing_details(jurnal_token.code, user.id))).devices

        if quota <= user.devices.count
          render json: {errors: "Device has reached allowed quota"}, status: :unprocessable_entity
          return
        else
          device = Device.create!({device_name: device_name,
                               device_id: device_id,
                               device_type: device_type,
                               access_token: SecureRandom.uuid,
                               setting_id: setting.id,
                               device_app_version: device_app_version,
                               device_os_version: device_os_version,
                               longitude: device_longitude,
                               latitude: device_latitude})
        end
      else 
        device.update_columns(setting_id: setting.id)
      end

      company_details_data = Jurnal::Company::CompanyDetailsResponse.new(
                              JSON.parse($jurnal.company_api.get_company_details(jurnal_token.code.downcase, user.id)))

      render json: { :settings_name => setting.name, :access_token => device.access_token, :user => user, :company => company_details_data }, status: :ok
      return
    else
      render json: {errors: "Invalid Code"}, status: :not_found
    end
  end

  def refresh
    user = @device.setting.user
    jurnal_token = JurnalAccessToken.where(user_id: user.id).last
    company_details_data = Jurnal::Company::CompanyDetailsResponse.new(
                              JSON.parse($jurnal.company_api.get_company_details(jurnal_token.code.downcase, user.id)))
    render json: {:company => company_details_data}, status: :ok
    return
  end

  def destroy
    @device.destroy
    render json: {ok: "ok"}, status: :ok
  end

  
  private
    def login_params
     params.require(:login).permit(:code, :device_id, :device_type,
                                         :device_name, :device_app_version, 
                                         :device_os_version, :longitude, 
                                         :latitude)
    end
end

