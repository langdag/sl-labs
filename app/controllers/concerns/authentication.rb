module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
    helper_method :current_user
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

    def require_authentication
      authenticate_request || render_unauthorized
    end

    attr_reader :current_user

    def authenticate_request
      return unless request.headers['Authorization'].present?

      token = request.headers['Authorization'].split(' ').last
      decoded = JsonWebToken.decode(token)
      return unless decoded

      @current_user = User.find_by(id: decoded[:user_id])
    end

    def render_unauthorized
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
end
