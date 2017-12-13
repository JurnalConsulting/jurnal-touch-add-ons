class DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_user

  def destroy
    @device = Device.find_by_id_and_setting_id(params['device_id'],params['id'])
    if @device.destroy
      render json: {device_id: @device.id}
    end
  end

  private
    def set_current_user
      @user = current_user
    end
end
