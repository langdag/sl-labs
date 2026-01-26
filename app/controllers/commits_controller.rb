class CommitsController < ApplicationController
  before_action :set_repository

  def index
    git_repo = @repository.git_repo
    return render json: [] unless git_repo

    head_sha = git_repo.resolve_ref("HEAD")

    if head_sha
      commit = GitObjectStore::GitObject.find(git_repo, head_sha)
      render json: [serialize_commit(commit)]
    else
      render json: []
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
      committer: commit.committer,
      tree: commit.tree,
      parents: commit.parents
    }
  end
end
