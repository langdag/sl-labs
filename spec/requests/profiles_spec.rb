require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let(:user) { User.create!(email_address: "profile@example.com", password: "password123", username: "profileuser") }
  
  # Helper to sign in
  before do
    post session_path, params: { email_address: user.email_address, password: "password123" }
    expect(response).to redirect_to(root_path)
  end

  describe "GET /:username" do
    it "shows the user profile" do
      get user_profile_path(user.username)
      expect(response).to have_http_status(200)
      expect(response.body).to include("profileuser")
    end
  end

  describe "GET /profile/edit" do
    it "shows the edit profile form" do
      get edit_profile_path
      expect(response).to have_http_status(200)
      expect(response.body).to include("Public profile")
    end
  end

  describe "PATCH /profile" do
    let(:valid_params) { { user: { full_name: "New Name", bio: "New Bio", status: "New Status" } } }

    it "updates the profile and redirects to the profile page" do
      patch profile_path, params: valid_params
      expect(response).to redirect_to(user_profile_path(user.username))
      follow_redirect!
      expect(response.body).to include("New Name")
      expect(response.body).to include("New Bio")
      expect(response.body).to include("New Status")
      
      user.reload
      expect(user.full_name).to eq("New Name")
    end

    it "can upload an avatar" do
      # Create a simple image for testing
      avatar = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'avatar.png'), 'image/png')
      patch profile_path, params: { user: { avatar: avatar } }
      
      expect(response).to redirect_to(user_profile_path(user.username))
      user.reload
      expect(user.avatar).to be_attached
    end
  end
end
