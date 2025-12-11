require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  let!(:user) { User.create!(email_address: 'test@example.com', password: 'password123') }
  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:valid_credentials) do
    {
      email_address: user.email_address,
      password: user.password
    }.to_json
  end
  let(:invalid_credentials) do
    {
      email_address: user.email_address,
      password: 'wrong_password'
    }.to_json
  end

  describe 'POST /login' do
    context 'when request is valid' do
      before { post '/login', params: valid_credentials, headers: headers }

      it 'returns an authentication token' do
        expect(json['token']).not_to be_nil
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when request is invalid' do
      before { post '/login', params: invalid_credentials, headers: headers }

      it 'returns a failure message' do
        expect(json['error']).to match(/Invalid username or password/)
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end
  end
end
