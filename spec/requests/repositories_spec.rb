require 'rails_helper'
require 'pry'

RSpec.describe 'Repositories API', type: :request do
  let!(:user) { User.create!(email_address: 'test@example.com', password: 'password123') }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }
  let(:valid_attributes) { { repository: { name: 'my-new-repo' } }.to_json }
  let(:invalid_attributes) { { repository: { name: '' } }.to_json }

  after(:all) do
    FileUtils.rm_rf(Rails.root.join('storage', 'repositories'))
  end

  describe 'PUT /repositories/:id' do
    let(:repository) { user.repositories.create!(name: 'test-repo') }
    let(:invalid_attributes) { { name: nil }.to_json }

    context 'when request is valid' do
      before do
        put "/repositories/#{repository.id}", params: valid_attributes, headers: headers
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'updates the repository' do
        expect(json['name']).to eq('my-new-repo')
      end
    end

    context 'when request is unauthorized' do
      before { put "/repositories/#{repository.id}", params: valid_attributes, headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when request is invalid' do
      let(:invalid_attributes) { { name: nil }.to_json }
      before { put "/repositories/#{repository.id}", params: invalid_attributes, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
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

  describe 'DELETE /repositories/:id' do
    let!(:repository) { user.repositories.create!(name: 'to-delete') }

    it 'returns status code 204' do
      delete "/repositories/#{repository.id}", headers: headers
      expect(response).to have_http_status(204)
    end

    it 'removes the directory from disk' do
      path = repository.disk_path
      delete "/repositories/#{repository.id}", headers: headers
      expect(Dir.exist?(path)).to be false
    end
  end
end
