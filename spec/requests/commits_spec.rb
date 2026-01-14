require 'rails_helper'
require 'fileutils'

RSpec.describe 'Commits API', type: :request do
  let!(:user) { User.create!(email_address: 'test@example.com', password: 'password123') }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json' } }
  let!(:repository) do
    repo = Repository.create!(name: 'commits-repo', user: user)
    RepositoryService.new(repo).call
    repo
  end

  after do
    FileUtils.rm_rf(repository.disk_path)
  end

  describe 'GET /repositories/:repository_id/commits' do
    context 'when repository is empty' do
      before { get "/repositories/#{repository.id}/commits", headers: headers }

      it 'returns empty list' do
        expect(json).to be_empty
        expect(response).to have_http_status(200)
      end
    end

    context 'when repository has commits' do
      before do
        # Manually create a commit in the repo
        repo_path = repository.disk_path.to_s
        git_repo = repository.git_repo
        
        # Write a tree
        tree_sha = GitObjectStore::GitObject.write_raw(git_repo, 'tree', "")
        
        # Write a commit
        commit_content = "tree #{tree_sha}\n" \
                         "author Me <me@example.com> 0 +0000\n" \
                         "committer Me <me@example.com> 0 +0000\n" \
                         "\n" \
                         "Initial commit"
        commit_sha = GitObjectStore::GitObject.write_raw(git_repo, 'commit', commit_content)
        
        # Update HEAD
        File.write(File.join(repo_path, '.git', 'refs', 'heads', 'main'), commit_sha)
        File.write(File.join(repo_path, '.git', 'HEAD'), "ref: refs/heads/main\n")
        
        get "/repositories/#{repository.id}/commits", headers: headers
      end

      it 'returns the commit' do
        expect(json).not_to be_empty
        expect(json.first['message']).to eq('Initial commit')
      end
    end
  end
end
