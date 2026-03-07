class CommitsController < ApplicationController
  before_action :set_repository

  def index
    @ref = params[:ref] || "HEAD"
    @path = params[:path] || ""

    # 1. Resolve Ref
    @sha, @ref = GitServiceClient.resolve_ref_with_fallback(@repository, @ref)
    
    if @sha.present?
      # 2. Get history via gRPC
      @commit_response = GitServiceClient.get_commits(@repository, @sha)
      @commits = @commit_response&.entries || []
      
      if params[:author].present?
        @commits = @commits.select { |c| c.author.downcase.include?(params[:author].downcase) }
      end
    else
      @commits = []
    end

    respond_to do |format|
      format.html # renders index.html.erb
      format.json { render json: @commits.map { |c| serialize_commit(c) } }
    end
  end

  def show
    @sha = params[:sha]
    
    # We use get_commits with limit = 1 essentially by just taking the first entry
    @commit_response = GitServiceClient.get_commits(@repository, @sha)
    @commit = @commit_response&.entries&.first
    
    if @commit.nil?
      redirect_to repository_pretty_root_path(username: @repository.user.username, repository_name: @repository.name), alert: "Commit not found."
    end
  end

  private

  def set_repository
    user = User.find_by!(username: params[:username])
    @repository = user.repositories.find_by!(name: params[:repository_name])
  end

  def serialize_commit(commit)
    {
      sha: commit.sha,
      message: commit.message,
      author: commit.author,
      tree: commit.tree_sha,
      parents: commit.parent_shas
    }
  end
end
