class RepositoriesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :set_repository, only: [:show, :edit, :update, :destroy]

  def index
    @repositories = current_user.repositories.all
    if params[:query].present?
      @repositories = @repositories.where("name ILIKE ?", "%#{params[:query]}%")
    end
    if params[:sort] == "name"
      @repositories = @repositories.order(name: :asc)
    elsif params[:sort] == "updated"
      @repositories = @repositories.order(updated_at: :desc)
    end
  end

  def new
    @repository = current_user.repositories.build
  end

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @repository.update(repository_params)
        format.html { redirect_to @repository, notice: "Repository was successfully updated." }
        format.json { render json: @repository, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @repository.errors }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @repository.destroy
    respond_to do |format|
      format.html { redirect_to repositories_path, notice: "Repository was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def create
    @repository = current_user.repositories.build(repository_params)

    respond_to do |format|
      if @repository.save
        format.html { redirect_to @repository, notice: "Repository was successfully created." }
        format.json { render json: @repository, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @repository.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_repository
    @repository = current_user.repositories.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to repositories_path, alert: "Repository not found."
  end

  def repository_params
    params.require(:repository).permit(:name)
  end
end
