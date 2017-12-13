# class Api::V1::SessionsController < Api::V1::ApiController
#   skip_before_action :require_login, only: [:create], raise: false

#   def create
#     # setting = Setting.find(params[:code]
#     p "start"
#     p params[:code]
#     setting = Setting.where(:code => params[:code]).first
#     # setting = Setting.find_by id: '1'.first
#     # p setting
#     # setting = Setting.find_by code: params[:code].first
#     p setting

#     if setting.present?
#       user = User.find(setting.user_id)
#       allow_token_to_be_used_only_once_for(user)
#       send_auth_token_for_valid_login_of(user)
#     else
#       render_unauthorized("Error with your login or password")
#     end



#     # if user = User.valid_login?(params[:email], params[:password])
#     #   allow_token_to_be_used_only_once_for(user)
#     #   send_auth_token_for_valid_login_of(user)
#     # else
#     #   render_unauthorized("Error with your login or password")
#     # end
#   end

#   def destroy
#     logout
#     head :ok
#   end

#   private

#   def send_auth_token_for_valid_login_of(user)
#     render json: { token: user.token }
#   end

#   def allow_token_to_be_used_only_once_for(user)
#     user.regenerate_token
#   end

#   def logout
#     current_user.invalidate_token
#   end
# end

module Api
  module V1
    class Users::SessionsController < Devise::SessionsController
      skip_before_action :verify_signed_out_user

      def create
        setting = Setting.where(:code => params[:code]).first
  
        if setting.present?
          user = User.find(setting.user_id)
            # user = warden.authenticate!(:scope => :user)
            token = Tiddle.create_and_return_token(user, request)
            # render json: { authentication_token: token,  }
            response = { :authentication_token => token, :user => user }
            respond_to do |format|
          format.json  { render :json => response }
        end
      end
    end

    def destroy
      if current_user && Tiddle.expire_token(current_user, request)
        head :ok
      else
        # Client tried to expire an invalid token
        render json: { error: 'invalid token' }, status: 401
      end
    end

    end
  end
end