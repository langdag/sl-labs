class AuthenticationController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:login, :create]
  allow_unauthenticated_access only: [:new, :create, :login]

  def new
  end

  def create
    @user = User.find_by(email_address: params[:email_address])
    if @user&.authenticate(params[:password])
      set_jwt_cookie(@user)
      redirect_to root_path, notice: "Signed in successfully"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unauthorized
    end
  end

  def login
    @user = User.find_by(email_address: params[:email_address])
    if @user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      render json: { token: token }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def destroy
    unset_jwt_cookie
    redirect_to root_path, notice: "Signed out successfully"
  end
end
