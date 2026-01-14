require 'rails_helper'
require 'fileutils'

RSpec.describe RepositoryService do
  let(:user) { User.create!(email_address: "service-test@example.com", password: "password123") }

  describe '#call' do
    describe 'initialization' do
      let(:repo) { Repository.create!(name: "new-repo", user: user) }
      let(:service) { RepositoryService.new(repo) }

      after do
        FileUtils.rm_rf(repo.disk_path) if repo.disk_path
      end

      it 'creates the git repository on disk when record was previously a new record' do
        expect(repo.previously_new_record?).to be true
        expect(Dir.exist?(repo.disk_path)).to be false
        
        service.call
        
        expect(Dir.exist?(repo.disk_path)).to be true
        expect(Dir.exist?(File.join(repo.disk_path, '.git'))).to be true
      end
    end

    describe 'renaming' do
      let(:repo) { Repository.create!(name: "original-name", user: user) }
      
      before do
        # Initialize the repository first
        RepositoryService.new(repo).call
      end

      after do
        FileUtils.rm_rf(repo.disk_path)
        # Clean up old path if it still exists
        old_path = Rails.root.join("storage", "repositories", "#{repo.id}_original-name")
        FileUtils.rm_rf(old_path)
      end

      it 'renames the directory on disk' do
        old_path = repo.disk_path
        expect(Dir.exist?(old_path)).to be true

        repo.update!(name: "new-name")
        expect(repo.saved_change_to_name?).to be true
        
        RepositoryService.new(repo).call
        
        expect(Dir.exist?(old_path)).to be false
        expect(Dir.exist?(repo.disk_path)).to be true
        expect(repo.disk_path.to_s).to include("new-name")
      end
    end

    describe 'cleanup' do
      let(:repo) { Repository.create!(name: "to-be-deleted", user: user) }
      let(:service) { RepositoryService.new(repo) }

      it 'removes the directory from disk when destroyed' do
        service.call
        expect(Dir.exist?(repo.disk_path)).to be true

        repo.destroy
        RepositoryService.new(repo).call

        expect(repo.destroyed?).to be true
        expect(Dir.exist?(repo.disk_path)).to be false
      end
    end
  end
end
