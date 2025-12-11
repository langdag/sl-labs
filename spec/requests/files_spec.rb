require 'rails_helper'
require 'fileutils'

RSpec.describe 'Files API', type: :request do
  let!(:user) { User.create!(email_address: 'test@example.com', password: 'password123') }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json' } }
  let!(:repository) { Repository.create!(name: 'files-repo', user: user) }

  before do
    repo_path = repository.disk_path.to_s
    git_repo = GitObjectStore::Repository.new(repo_path)
    
    # Create a blob
    @blob_content = "Hello World"
    @blob_sha = GitObjectStore::GitObject.write_raw(git_repo, 'blob', @blob_content)
    
    # Create a tree containing the blob
    # entry: mode name\0sha (20-byte binary)
    sha_binary = [@blob_sha].pack('H*')
    tree_entry = "100644 test.txt\0#{sha_binary}"
    @tree_sha = GitObjectStore::GitObject.write_raw(git_repo, 'tree', tree_entry)
  end

  after do
    FileUtils.rm_rf(Rails.root.join('storage', 'repositories', 'files-repo'))
  end

  describe 'GET /repositories/:repository_id/trees/:sha' do
    it 'returns the tree entries' do
      get "/repositories/#{repository.id}/trees/#{@tree_sha}", headers: headers
      
      expect(response).to have_http_status(200)
      expect(json).to be_an(Hash)
      expect(json['entries']).to be_an(Array)
      expect(json['entries'].first['name']).to eq('test.txt')
      expect(json['entries'].first['sha']).to eq(@blob_sha)
    end
  end

  describe 'GET /repositories/:repository_id/blobs/:sha' do
    it 'returns the blob content' do
      get "/repositories/#{repository.id}/blobs/#{@blob_sha}", headers: headers
      
      expect(response).to have_http_status(200)
      expect(json['content']).to eq(@blob_content)
    end
  end
end
