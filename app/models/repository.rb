class Repository < ApplicationRecord
  belongs_to :user
  has_many :commits, dependent: :destroy
  has_many :activities, dependent: :destroy
  validates :name, presence: true

  def disk_path
    Rails.root.join("storage", "repositories", "#{id}_#{name}")
  end

  def git_repo
    return nil unless File.directory?(disk_path.join("objects"))
    @git_repo ||= GitObjectStore::Repository.new(disk_path)
  end
end
