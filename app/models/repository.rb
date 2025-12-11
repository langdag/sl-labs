class Repository < ApplicationRecord
  belongs_to :user
  validates :name, presence: true

  after_create_commit :initialize_git_repository

  def disk_path
    Rails.root.join("storage", "repositories", name)
  end

  def git_repo
    @git_repo ||= GitObjectStore::Repository.new(disk_path)
  end

  private

  def initialize_git_repository
    GitObjectStore::Repository.init(disk_path)
  end
end
