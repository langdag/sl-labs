require 'rails_helper'
require 'fileutils'

RSpec.describe CommitIndexerService do
  let(:user) { User.create!(email_address: "alice@example.com", password: "password", username: "alice") }
  let(:repository) { Repository.create!(name: "test-repo", user: user) }
  let(:git_repo) { repository.git_repo }
  
  before do
    RepositoryService.new(repository).call
  end

  after do
    FileUtils.rm_rf(repository.disk_path)
  end

  describe "#index" do
    it "parses commits from disk and saves them to the database" do
      # 1. Create a dummy commit structure on disk using GitObjectStore
      blob_sha = GitObjectStore::GitObject.write_raw(git_repo, 'blob', "Content")
      
      sha_binary = [blob_sha].pack('H*')
      tree_entry = "100644 file.txt\0#{sha_binary}"
      tree_sha = GitObjectStore::GitObject.write_raw(git_repo, 'tree', tree_entry)
      
      timestamp = Time.now.to_i
      author = "Alice <alice@example.com> #{timestamp} +0000"
      commit_content = "tree #{tree_sha}\nauthor #{author}\ncommitter #{author}\n\nInitial commit"
      commit_sha = GitObjectStore::GitObject.write_raw(git_repo, 'commit', commit_content)
      
      # Set HEAD to this commit
      File.write(git_repo.repo_file('refs', 'heads', 'main', mkdir: true), commit_sha)
      File.write(git_repo.repo_file('HEAD'), "ref: refs/heads/main")
      
      # 2. Run indexer
      indexer = CommitIndexerService.new(repository)
      expect {
        indexer.index("HEAD")
      }.to change(Commit, :count).by(1)
       .and change(Activity, :count).by(1)
      
      # 3. Verify data
      db_commit = Commit.last
      expect(db_commit.sha).to eq(commit_sha)
      expect(db_commit.message).to eq("Initial commit")
      expect(db_commit.user).to eq(user)
      expect(db_commit.author_name).to eq("Alice")
      expect(db_commit.author_email).to eq("alice@example.com")
    end

    it "handles multiple commits and parents" do
      # Create 2 commits
      # Commit 1
      blob_sha = GitObjectStore::GitObject.write_raw(git_repo, 'blob', "v1")
      tree_sha = GitObjectStore::GitObject.write_raw(git_repo, 'tree', "100644 f\0#{[blob_sha].pack('H*')}")
      author = "Alice <alice@example.com> #{Time.now.to_i} +0000"
      c1_sha = GitObjectStore::GitObject.write_raw(git_repo, 'commit', "tree #{tree_sha}\nauthor #{author}\ncommitter #{author}\n\nC1")
      
      # Commit 2
      c2_sha = GitObjectStore::GitObject.write_raw(git_repo, 'commit', "tree #{tree_sha}\nparent #{c1_sha}\nauthor #{author}\ncommitter #{author}\n\nC2")
      
      File.write(git_repo.repo_file('refs', 'heads', 'main', mkdir: true), c2_sha)
      
      indexer = CommitIndexerService.new(repository)
      expect {
        indexer.index("refs/heads/main")
      }.to change(Commit, :count).by(2)
      
      expect(Commit.find_by(sha: c2_sha).parent_shas).to eq([c1_sha])
    end

    it "skips and logs error for malformed author data" do
      blob_sha = GitObjectStore::GitObject.write_raw(git_repo, 'blob', "Content")
      tree_entry = "100644 file.txt\0#{[blob_sha].pack('H*')}"
      tree_sha = GitObjectStore::GitObject.write_raw(git_repo, 'tree', tree_entry)
      
      # Malformed author (missing email and timestamp)
      author = "Bad Author String"
      commit_content = "tree #{tree_sha}\nauthor #{author}\ncommitter #{author}\n\nBad commit"
      commit_sha = GitObjectStore::GitObject.write_raw(git_repo, 'commit', commit_content)
      
      File.write(git_repo.repo_file('refs', 'heads', 'main', mkdir: true), commit_sha)
      
      indexer = CommitIndexerService.new(repository)
      
      expect(Rails.logger).to receive(:error).with(/Failed to index commit #{commit_sha}/)
      
      expect {
        indexer.index("refs/heads/main")
      }.not_to change(Commit, :count)
    end

    it "skips and logs error for unknown user" do
      blob_sha = GitObjectStore::GitObject.write_raw(git_repo, 'blob', "Content")
      tree_sha = GitObjectStore::GitObject.write_raw(git_repo, 'tree', "100644 file.txt\0#{[blob_sha].pack('H*')}")
      
      # Valid format but unknown email
      author = "Stranger <stranger@example.com> #{Time.now.to_i} +0000"
      commit_content = "tree #{tree_sha}\nauthor #{author}\ncommitter #{author}\n\nStranger commit"
      commit_sha = GitObjectStore::GitObject.write_raw(git_repo, 'commit', commit_content)
      
      File.write(git_repo.repo_file('refs', 'heads', 'main', mkdir: true), commit_sha)
      
      indexer = CommitIndexerService.new(repository)
      
      expect(Rails.logger).to receive(:error).with(/User not found for email: stranger@example.com/)
      
      expect {
        indexer.index("refs/heads/main")
      }.not_to change(Commit, :count)
    end
  end
end
