require 'rails_helper'

RSpec.describe 'Repositories API', type: :request do
  let!(:user) { User.create!(email_address: 'test@example.com', password: 'password123') }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json' } }
  let(:valid_attributes) { { name: 'my-new-repo' }.to_json }

  after do
    FileUtils.rm_rf(Rails.root.join('storage', 'repositories', 'my-new-repo'))
  end

  describe 'POST /repositories' do
    context 'when request is valid' do
      before do
        post '/repositories', params: valid_attributes, headers: headers
      end

      it 'creates a repository' do
        expect(json['name']).to eq('my-new-repo')
        expect(json['user_id']).to eq(user.id)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when request is unauthorized' do
      before { post '/repositories', params: valid_attributes, headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when request is invalid' do
      let(:invalid_attributes) { { name: nil }.to_json }
      before { post '/repositories', params: invalid_attributes, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end
end
