require 'rails_helper'
require 'fileutils'

RSpec.describe Repository, type: :model do
  let(:user) { User.create!(email_address: "test@example.com", password: "password123") }

  describe 'validations' do
    it 'is valid with a name and user' do
      repo = Repository.new(name: 'test-repo', user: user)
      expect(repo).to be_valid
    end

    it 'is invalid without a name' do
      repo = Repository.new(name: nil, user: user)
      expect(repo).not_to be_valid
      expect(repo.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a user' do
      repo = Repository.new(name: 'test-repo', user: nil)
      expect(repo).not_to be_valid
      expect(repo.errors[:user]).to include("must exist")
    end
  end

  describe '#disk_path' do
    it 'returns the expected path' do
      repo = Repository.new(id: 123, name: 'test-repo')
      expect(repo.disk_path.to_s).to end_with('storage/repositories/123_test-repo')
    end
  end

  describe '#git_repo' do
    let(:repo) { Repository.create!(name: "test-accessor-#{Time.now.to_i}", user: user) }
    let(:disk_path) { repo.disk_path }

    before do
      FileUtils.mkdir_p(File.dirname(disk_path))
      GitObjectStore::Repository.init(disk_path)
    end

    after do
      FileUtils.rm_rf(disk_path)
    end

    it 'returns a GitObjectStore::Repository instance' do
      git_store = repo.git_repo
      expect(git_store).to be_a(GitObjectStore::Repository)
      expect(git_store.worktree.to_s).to eq(disk_path.to_s)
    end
  end
end
