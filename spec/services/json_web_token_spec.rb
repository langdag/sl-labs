require 'rails_helper'

RSpec.describe JsonWebToken do
  let(:payload) { { user_id: 1 } }
  let(:token) { described_class.encode(payload) }

  describe '.encode' do
    it 'returns a JWT token' do
      expect(token).to be_a(String)
      decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
      expect(decoded['user_id']).to eq(1)
    end
  end

  describe '.decode' do
    it 'returns the payload for a valid token' do
      decoded = described_class.decode(token)
      expect(decoded[:user_id]).to eq(1)
    end

    it 'returns nil for an expired token' do
      expired_token = described_class.encode(payload, 24.hours.ago)
      decoded = described_class.decode(expired_token)
      expect(decoded).to be_nil
    end

    it 'returns nil for an invalid token' do
      decoded = described_class.decode('invalid_token')
      expect(decoded).to be_nil
    end
  end
end
