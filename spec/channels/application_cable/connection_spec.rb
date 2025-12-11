require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { User.create!(email_address: 'test@example.com', password: 'password123') }
  let(:token) { JsonWebToken.encode(user_id: user.id) }

  it "successfully connects with valid token" do
    connect "/cable", params: { token: token }
    expect(connection.current_user).to eq(user)
  end

  it "rejects connection with invalid token" do
    expect { connect "/cable", params: { token: 'invalid' } }.to have_rejected_connection
  end

  it "rejects connection without token" do
    expect { connect "/cable" }.to have_rejected_connection
  end
end
