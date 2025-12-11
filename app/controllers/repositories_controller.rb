class RepositoriesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @repository = current_user.repositories.build(repository_params)

    if @repository.save
      render json: @repository, status: :created
    else
      render json: { errors: @repository.errors }, status: :unprocessable_entity
    end
  end

  private

  def repository_params
    params.require(:repository).permit(:name)
  end
end
