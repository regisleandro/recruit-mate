require 'rails_helper'

RSpec.describe 'API V1 Recruiters', type: :request do
  let(:user) { create(:user) }
  let(:recruiter) { create(:recruiter, user: user) }
  let(:valid_attributes) { { name: 'New Recruiter', prompt: 'Some prompt', user_id: user.id } }
  let(:invalid_attributes) { { name: '', user_id: nil } }

  before do
    stub_authentication(user)
  end

  describe 'GET /api/v1/recruiters' do
    it 'returns a list of recruiters when authenticated' do
      create_list(:recruiter, 3, user: user)

      get '/api/v1/recruiters', headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(3)
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      get '/api/v1/recruiters'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/recruiters/:id' do
    it 'returns the requested recruiter when authenticated' do
      get "/api/v1/recruiters/#{recruiter.id}", headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(recruiter.id.to_s)
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      get "/api/v1/recruiters/#{recruiter.id}"

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns not found when recruiter doesn't exist" do
      get '/api/v1/recruiters/0', headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/recruiters' do
    context 'with valid parameters' do
      it 'creates a new recruiter' do
        expect do
          post '/api/v1/recruiters', params: { recruiter: valid_attributes }.to_json, headers: auth_headers_with_token
        end.to change(Recruiter, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new recruiter' do
        expect do
          post '/api/v1/recruiters', params: { recruiter: invalid_attributes }.to_json, headers: auth_headers_with_token
        end.not_to change(Recruiter, :count)

        expect(response).to have_http_status(422)
      end
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      post '/api/v1/recruiters', params: { recruiter: valid_attributes }.to_json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PUT /api/v1/recruiters/:id' do
    let(:new_attributes) { { name: 'Updated Recruiter', prompt: 'Updated prompt' } }

    context 'with valid parameters' do
      it 'updates the requested recruiter' do
        put "/api/v1/recruiters/#{recruiter.id}", params: { recruiter: new_attributes }.to_json, headers: auth_headers_with_token
        recruiter.reload

        expect(response).to have_http_status(:ok)
        expect(recruiter.name).to eq('Updated Recruiter')
        expect(recruiter.prompt).to eq('Updated prompt')
      end
    end

    context 'with invalid parameters' do
      it "renders errors and doesn't update the recruiter" do
        put "/api/v1/recruiters/#{recruiter.id}", params: { recruiter: invalid_attributes }.to_json, headers: auth_headers_with_token

        expect(response).to have_http_status(422)
      end
    end

    it "returns not found when recruiter doesn't exist" do
      put '/api/v1/recruiters/0', params: { recruiter: new_attributes }.to_json, headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/recruiters/:id' do
    it 'destroys the requested recruiter' do
      recruiter # create recruiter first

      expect do
        delete "/api/v1/recruiters/#{recruiter.id}", headers: auth_headers_with_token
      end.to change(Recruiter, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns not found when recruiter doesn't exist" do
      delete '/api/v1/recruiters/0', headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end
end
