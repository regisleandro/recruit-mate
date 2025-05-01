require 'rails_helper'

RSpec.describe 'API V1 Candidates', type: :request do
  let(:user) { create(:user) }
  let(:candidate) { create(:candidate, user: user) }
  let(:valid_attributes) do
    {
      name: 'Test Candidate',
      cpf: '12345678901',
      curriculum_summary: 'Test summary',
      cellphone_number: '1234567890',
      user_id: user.id
    }
  end
  let(:invalid_attributes) { { name: '', cpf: '123' } }

  before do
    stub_authentication(user)
  end

  describe 'GET /api/v1/candidates' do
    it 'returns a list of candidates when authenticated' do
      create_list(:candidate, 3, user: user)

      get '/api/v1/candidates', headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(3)
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      get '/api/v1/candidates'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/candidates/:id' do
    it 'returns the requested candidate when authenticated' do
      get "/api/v1/candidates/#{candidate.id}", headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(candidate.id.to_s)
      expect(json_response['data']['attributes']['name']).to eq(candidate.name)
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      get "/api/v1/candidates/#{candidate.id}"

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns not found when candidate doesn't exist" do
      get '/api/v1/candidates/0', headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/candidates' do
    context 'with valid parameters' do
      it 'creates a new candidate' do
        expect do
          post '/api/v1/candidates', params: { candidate: valid_attributes }.to_json, headers: auth_headers_with_token
        end.to change(Candidate, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['data']['attributes']['name']).to eq('Test Candidate')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new candidate' do
        expect do
          post '/api/v1/candidates', params: { candidate: invalid_attributes }.to_json, headers: auth_headers_with_token
        end.not_to change(Candidate, :count)

        expect(response).to have_http_status(422)
      end
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      post '/api/v1/candidates', params: { candidate: valid_attributes }.to_json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PUT /api/v1/candidates/:id' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: 'Updated Candidate' } }

      it 'updates the requested candidate' do
        put "/api/v1/candidates/#{candidate.id}", params: { candidate: new_attributes }.to_json, headers: auth_headers_with_token
        candidate.reload

        expect(response).to have_http_status(:ok)
        expect(candidate.name).to eq('Updated Candidate')
      end
    end

    context 'with invalid parameters' do
      it "renders errors and doesn't update the candidate" do
        put "/api/v1/candidates/#{candidate.id}", params: { candidate: invalid_attributes }.to_json, headers: auth_headers_with_token

        expect(response).to have_http_status(422)
      end
    end

    it "returns not found when candidate doesn't exist" do
      put '/api/v1/candidates/0', params: { candidate: { name: 'Test' } }.to_json, headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/candidates/:id' do
    it 'destroys the requested candidate' do
      candidate # create candidate first

      expect do
        delete "/api/v1/candidates/#{candidate.id}", headers: auth_headers_with_token
      end.to change(Candidate, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns not found when candidate doesn't exist" do
      delete '/api/v1/candidates/0', headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end
end
