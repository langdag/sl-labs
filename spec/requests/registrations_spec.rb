require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe "POST /registrations" do
    let(:valid_params) do
      {
        user: {
          email_address: "newuser@example.com",
          username: "newuser",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    it "creates a new user with a username" do
      expect {
        post registrations_path, params: valid_params
      }.to change(User, :count).by(1)

      user = User.last
      expect(user.username).to eq("newuser")
      expect(response).to redirect_to(root_path)
    end

    it "fails to create a user without a username" do
      invalid_params = valid_params.deep_merge(user: { username: "" })
      expect {
        post registrations_path, params: invalid_params
      }.not_to change(User, :count)
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
