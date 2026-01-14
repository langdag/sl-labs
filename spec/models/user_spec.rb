require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.new(email_address: "test@example.com", password: "password123", username: "testuser") }

  it "is valid with a username" do
    expect(user).to be_valid
  end

  it "is invalid without a username on update" do
    user.save!
    user.username = nil
    expect(user).not_to be_valid
  end

  it "validates uniqueness of username" do
    user.save!
    other_user = User.new(email_address: "other@example.com", password: "password123", username: "testuser")
    expect(other_user).not_to be_valid
  end

  it "validates format of username" do
    user.username = "invalid username"
    expect(user).not_to be_valid
    user.username = "valid-user_123"
    expect(user).to be_valid
  end

  it "returns display_name" do
    expect(user.display_name).to eq("testuser")
    user.full_name = "Real Name"
    expect(user.display_name).to eq("Real Name")
  end
end
