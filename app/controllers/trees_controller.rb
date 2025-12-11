class TreesController < ApplicationController
  before_action :set_repository

  def show
    sha = params[:sha]
    git_repo = @repository.git_repo
    
    begin
      tree = GitObjectStore::GitObject.find(git_repo, sha)
      if tree.is_a?(GitObjectStore::Tree)
        render json: serialize_tree(tree)
      else
        render json: { error: 'Not a tree' }, status: :unprocessable_entity
      end
    rescue Errno::ENOENT
      render json: { error: 'Tree not found' }, status: :not_found
    end
  end

  private

  def set_repository
    @repository = current_user.repositories.find(params[:repository_id])
  end

  def serialize_tree(tree)
    {
      sha: tree.sha,
      entries: tree.entries.map do |entry|
        {
          mode: entry[:mode],
          name: entry[:name],
          sha: entry[:sha]
        }
      end
    }
  end
end
