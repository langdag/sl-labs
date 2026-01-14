class Repository < ApplicationRecord
  belongs_to :user
  validates :name, presence: true

  def disk_path
    Rails.root.join("storage", "repositories", "#{id}_#{name}")
  end

  def git_repo
    @git_repo ||= GitObjectStore::Repository.new(disk_path)
  end
end
