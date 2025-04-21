require 'rails_helper'

RSpec.describe 'API V1 Companies', type: :request do
  let(:user) { create(:user) }
  let(:company) { create(:company, user: user) }
  let(:valid_attributes) { { name: 'Test Company', user_id: user.id } }
  let(:invalid_attributes) { { name: '' } }

  before do
    stub_authentication(user)
  end

  describe 'GET /api/v1/companies' do
    it 'returns a list of companies when authenticated' do
      create_list(:company, 3, user: user)

      get '/api/v1/companies', headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(3)
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      get '/api/v1/companies'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/companies/:id' do
    it 'returns the requested company when authenticated' do
      get "/api/v1/companies/#{company.id}", headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(company.id.to_s)
      expect(json_response['data']['attributes']['name']).to eq(company.name)
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      get "/api/v1/companies/#{company.id}"

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns not found when company doesn't exist" do
      get '/api/v1/companies/0', headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/companies' do
    context 'with valid parameters' do
      it 'creates a new company' do
        expect do
          post '/api/v1/companies', params: { company: valid_attributes }.to_json, headers: auth_headers_with_token
        end.to change(Company, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['data']['attributes']['name']).to eq('Test Company')
      end

      it 'associates the company with the current user' do
        post '/api/v1/companies', params: { company: valid_attributes }.to_json, headers: auth_headers_with_token

        expect(Company.last.user).to eq(user)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new company' do
        expect do
          post '/api/v1/companies', params: { company: invalid_attributes }.to_json, headers: auth_headers_with_token
        end.not_to change(Company, :count)

        expect(response).to have_http_status(422)
      end
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      post '/api/v1/companies', params: { company: valid_attributes }.to_json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PUT /api/v1/companies/:id' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: 'Updated Company' } }

      it 'updates the requested company' do
        put "/api/v1/companies/#{company.id}", params: { company: new_attributes }.to_json, headers: auth_headers_with_token
        company.reload

        expect(response).to have_http_status(:ok)
        expect(company.name).to eq('Updated Company')
      end
    end

    context 'with invalid parameters' do
      it "renders errors and doesn't update the company" do
        put "/api/v1/companies/#{company.id}", params: { company: invalid_attributes }.to_json, headers: auth_headers_with_token

        expect(response).to have_http_status(422)
        expect(company.reload.name).not_to eq('')
      end
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      put "/api/v1/companies/#{company.id}", params: { company: { name: 'Test' } }.to_json

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns not found when company doesn't exist" do
      put '/api/v1/companies/0', params: { company: { name: 'Test' } }.to_json, headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/companies/:id' do
    it 'destroys the requested company' do
      company # create company first

      expect do
        delete "/api/v1/companies/#{company.id}", headers: auth_headers_with_token
      end.to change(Company, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      delete "/api/v1/companies/#{company.id}"

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns not found when company doesn't exist" do
      delete '/api/v1/companies/0', headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end
end
