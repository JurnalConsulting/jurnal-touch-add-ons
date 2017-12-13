class Api::V1::ApiController < ActionController::API
  # before_action :set_raven_context
  
  # # it works because we have tiddle and X-USER-EMAIL and X-USER-TOKEN  
  before_action :authenticate_user!

  # before_action :reset_session
  # config.autoload_paths << Rails.root.join('lib')

  #skip_before_action :verify_authenticity_token

  def require_login
    authenticate_token || render_unauthorized("Access denied")
  end

  def current_user
    @current_user ||= authenticate_token
  end

  protected

  def render_unauthorized(message)
    errors = { errors: [ { detail: message } ] }
    render json: errors, status: :unauthorized
  end

  private

  def authenticate_user!
    @device ||= Device.where(access_token: request.headers["HTTP_ACCESS_TOKEN"] || request.headers["ACCESS-TOKEN"]).first
    if !@device.present?
      render json: {}, status: :unauthorized
      return
    end
    @setting ||= @device.setting
    @user ||= @device.setting.user
    @jurnal_access_token = JurnalAccessToken.where(user_id: @user.id).last
  end
  
  def set_raven_context
    # Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
    return unless current_user
    Raven.user_context('id' => current_user.id,
                        'email' => current_user.email,
                        'fullname' => current_user.fullname)

  end

  def pagination_dict(object)
    {
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.prev_page, # use object.previous_page when using will_paginate
      total_pages: object.total_pages,
      total_count: object.total_count
    }
  end
end