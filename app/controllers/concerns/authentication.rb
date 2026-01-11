module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?, :current_user
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      current_user.present?
    end

    def current_user
      @current_user ||= resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      if request.headers["Authorization"].present?
        authenticate_with_token
      elsif cookies.signed[:jwt].present?
        authenticate_with_cookie
      end
    end

    def authenticate_with_token
      token = request.headers["Authorization"].split(" ").last
      decode_and_find_user(token)
    end

    def authenticate_with_cookie
      decode_and_find_user(cookies.signed[:jwt])
    end

    def decode_and_find_user(token)
      decoded = JsonWebToken.decode(token)
      User.find_by(id: decoded[:user_id]) if decoded
    end

    def request_authentication
      respond_to do |format|
        format.html { redirect_to login_path }
        format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
      end
    end

    def set_jwt_cookie(user)
      token = JsonWebToken.encode(user_id: user.id)
      cookies.signed[:jwt] = {
        value: token,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax,
        expires: 24.hours.from_now
      }
    end

    def unset_jwt_cookie
      cookies.delete(:jwt)
    end
end
