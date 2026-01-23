class User < ApplicationRecord
  has_secure_password
  has_many :repositories, dependent: :destroy
  has_many :commits, dependent: :nullify
  has_many :activities, dependent: :destroy
  has_one_attached :avatar

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :username, presence: true, uniqueness: { case_sensitive: false }, 
            format: { with: /\A[a-zA-Z0-9_\-]+\z/, message: "can only contain letters, numbers, underscores, and hyphens" },
            length: { maximum: 39 }
  
  validates :bio, length: { maximum: 160 }
  validates :status, length: { maximum: 50 }

  def display_name
    full_name.presence || username || email_address.split('@').first
  end

  def daily_contributions
    commits.group("DATE(committed_at)").count
  end

  def total_contributions_last_year
    commits.where("committed_at > ?", 1.year.ago).count
  end
end
