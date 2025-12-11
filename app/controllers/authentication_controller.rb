class AuthenticationController < ApplicationController
  skip_before_action :verify_authenticity_token
  allow_unauthenticated_access only: [:login]

  def login
    @user = User.find_by(email_address: params[:email_address])
    if @user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      render json: { token: token }, status: :ok
    else
      render json: { error: 'Invalid username or password' }, status: :unauthorized
    end
  end
end
