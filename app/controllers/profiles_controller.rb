class ProfilesController < ApplicationController
  before_action :set_user, only: [:show]
  def show
    @repositories = @user.repositories.order(updated_at: :desc)
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to user_profile_path(@user.username), notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by_username(params[:username])
  end

  def profile_params
    params.require(:user).permit(:username, :full_name, :bio, :location, :company, :website, :twitter_handle, :status, :avatar)
  end
end
