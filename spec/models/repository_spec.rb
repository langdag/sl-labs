require 'rails_helper'
require 'fileutils'

RSpec.describe Repository, type: :model do
  describe 'validations' do
    it 'is valid with a name' do
      repo = Repository.new(name: 'test-repo')
      expect(repo).to be_valid
    end

    it 'is invalid without a name' do
      repo = Repository.new(name: nil)
      expect(repo).not_to be_valid
      expect(repo.errors[:name]).to include("can't be blank")
    end
  end

  describe '#create' do
    let(:repo_name) { "test-disk-creation-#{Time.now.to_i}" }
    let(:repo) { Repository.create(name: repo_name) }

    after do
      FileUtils.rm_rf(repo.disk_path) if repo&.disk_path
    end

    it 'creates a git repository on disk' do
      expect(repo).to be_persisted
      expect(Dir.exist?(repo.disk_path)).to be true
      expect(Dir.exist?(File.join(repo.disk_path, '.git'))).to be true
    end
  end

  describe '#git_repo' do
    let(:repo) { Repository.create(name: "test-accessor-#{Time.now.to_i}") }

    after do
      FileUtils.rm_rf(repo.disk_path) if repo&.disk_path
    end

    it 'returns a GitObjectStore::Repository instance' do
      git_store = repo.git_repo
      expect(git_store).to be_a(GitObjectStore::Repository)
      expect(git_store.worktree.to_s).to eq(repo.disk_path.to_s)
    end
  end
end
