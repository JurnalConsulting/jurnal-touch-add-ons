class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  # Prevent CSRF attacks, except for JSON requests (API clients)
  protect_from_forgery unless: -> { request.format.json? }

  # Require authentication and do not set a session cookie for JSON requests (API clients)
  before_action :authenticate_user!, :do_not_set_cookie, if: -> { request.format.json? }

  protect_from_forgery with: :exception
  before_action :allow_cors
  after_action :allow_iframe
  before_action :set_locale

  def self.force_ssl(options = {})
    host = options.delete(:host)
    before_action(options) do
      if !request.ssl? && !Rails.env.development? &&
         !(respond_to?(:allow_http?) && allow_http?) && ENV['USE_HTTPS'] == "true"
        redirect_options = {:protocol => 'https://', :status => :moved_permanently}
        redirect_options.merge!(:host => host) if host
        redirect_options.merge!(:params => request.query_parameters)
        redirect_to redirect_options
      end
    end
  end

  force_ssl

  protected
    def set_raven_context
      if ENV['SENTRY_ACTIVE'] == 'true'.freeze
        Raven.user_context({
          user_id: current_user.try(:id)
        })
      end
    end

    def authenticate_user!
      if user_signed_in?
        super
      else
        redirect_to root_path
      end
    end

  private
    def set_raven_context
      if ENV['SENTRY_ACTIVE'] == 'true'.freeze
        Raven.user_context({
          user_id: current_user.try(:id)
        })
      end
    end

    def allow_cors
      headers["Access-Control-Allow-Origin"] = "*"
      headers["Access-Control-Allow-Methods"] = "POST, PUT, DELETE, GET, OPTIONS"
      headers["Access-Control-Request-Method"] = "*"
      headers["Access-Control-Allow-Headers"] = "Origin, X-Requested-With, Content-Type, Accept, Authorization"
    end

    def allow_iframe
      response.headers['X-Frame-Options'] = "ALLOW-FROM #{ENV['JURNAl_ROOT_PATH']}"
    end
    
    def set_locale
      I18n.locale = I18n.default_locale
    end

    def do_not_set_cookie
      request.session_options[:skip] = true
    end
end
