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
    @ref = params[:ref] || "HEAD"
    @path = params[:path] || ""

    service = TreeNavigationService.new(@repository, @ref, @path)
    @item = service.call
    @ref = service.resolved_ref # Use detected branch name (master/main) in the view

    # If at the landing page (no ref/path) and content exists, redirect to the default branch
    if params[:ref].blank? && @item.is_a?(GitObjectStore::Tree)
      return redirect_to repository_tree_path(
        username: @repository.user.username,
        repository_name: @repository.name,
        ref: @ref,
        path: nil
      )
    end

    if @item.is_a?(GitObjectStore::Blob)
      @content = @item.data.force_encoding('UTF-8').scrub
      render :file_content, formats: [:html]
    elsif @item.is_a?(GitObjectStore::Tree)
      @entries = @item.entries
      @last_commits = {} 
      render :show
    else
      # If at root and nothing found, show setup page
      if @path.blank?
        @entries = []
        render :show
      else
        redirect_to repository_pretty_root_path(username: @repository.user.username, repository_name: @repository.name), alert: "Not found"
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @repository.update(repository_params)
        RepositoryService.new(@repository).call

        format.html { redirect_to repository_pretty_root_path(username: @repository.user.username, repository_name: @repository.name), notice: "Repository was successfully updated." }
        format.json { render json: @repository, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @repository.errors }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @repository.destroy
    RepositoryService.new(@repository).call

    respond_to do |format|
      format.html { redirect_to repositories_path, notice: "Repository was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def create
    @repository = current_user.repositories.build(repository_params)

    respond_to do |format|
      if @repository.save
        RepositoryService.new(@repository).call
        format.html { redirect_to repository_pretty_root_path(username: @repository.user.username, repository_name: @repository.name), notice: "Repository was successfully created." }
        format.json { render json: @repository, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @repository.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_repository
    user = User.find_by!(username: params[:username])
    @repository = user.repositories.find_by!(name: params[:repository_name])
  rescue ActiveRecord::RecordNotFound
    redirect_to repositories_path, alert: "Repository not found."
  end

  def repository_params
    params.require(:repository).permit(:name)
  end
end
