class BlobsController < ApplicationController
  before_action :set_repository

  def show
    sha = params[:sha]
    git_repo = @repository.git_repo
    return render json: { error: 'Repository not found on disk' }, status: :not_found unless git_repo
    
    begin
      blob = GitObjectStore::GitObject.find(git_repo, sha)
      if blob.is_a?(GitObjectStore::Blob)
        render json: serialize_blob(blob)
      else
        render json: { error: 'Not a blob' }, status: :unprocessable_entity
      end
    rescue Errno::ENOENT
      render json: { error: 'Blob not found' }, status: :not_found
    end
  end

  private

  def set_repository
    @repository = current_user.repositories.find(params[:repository_id])
  end

  def serialize_blob(blob)
    {
      sha: blob.sha,
      content: blob.data.force_encoding('UTF-8').scrub
    }
  end
end
