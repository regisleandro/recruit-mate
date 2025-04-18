require 'rails_helper'

RSpec.describe 'Companies API', type: :request do
  let(:user) { create(:user) }
  let(:company) { create(:company, user: user) }
  let(:valid_attributes) { { name: 'Test Company' } }
  let(:invalid_attributes) { { name: '' } }

  before do
    stub_authentication(user)
  end

  describe 'GET /companies' do
    it 'returns a list of companies when authenticated' do
      create_list(:company, 3, user: user)

      get '/companies', headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(3)
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      get '/companies'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /companies/:id' do
    it 'returns the requested company when authenticated' do
      get "/companies/#{company.id}", headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(company.id.to_s)
      expect(json_response['data']['attributes']['name']).to eq(company.name)
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      get "/companies/#{company.id}"

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns not found when company doesn't exist" do
      get '/companies/0', headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /companies' do
    context 'with valid parameters' do
      it 'creates a new company' do
        expect do
          post '/companies', params: { company: valid_attributes }.to_json, headers: auth_headers_with_token
        end.to change(Company, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['data']['attributes']['name']).to eq('Test Company')
      end

      it 'associates the company with the current user' do
        post '/companies', params: { company: valid_attributes }.to_json, headers: auth_headers_with_token

        expect(Company.last.user).to eq(user)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new company' do
        expect do
          post '/companies', params: { company: invalid_attributes }.to_json, headers: auth_headers_with_token
        end.not_to change(Company, :count)

        expect(response).to have_http_status(422)
      end
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      post '/companies', params: { company: valid_attributes }.to_json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PUT /companies/:id' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: 'Updated Company' } }

      it 'updates the requested company' do
        put "/companies/#{company.id}", params: { company: new_attributes }.to_json, headers: auth_headers_with_token
        company.reload

        expect(response).to have_http_status(:ok)
        expect(company.name).to eq('Updated Company')
      end
    end

    context 'with invalid parameters' do
      it "renders errors and doesn't update the company" do
        put "/companies/#{company.id}", params: { company: invalid_attributes }.to_json, headers: auth_headers_with_token

        expect(response).to have_http_status(422)
        expect(company.reload.name).not_to eq('')
      end
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      put "/companies/#{company.id}", params: { company: { name: 'Test' } }.to_json

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns not found when company doesn't exist" do
      put '/companies/0', params: { company: { name: 'Test' } }.to_json, headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /companies/:id' do
    it 'destroys the requested company' do
      company # create company first

      expect do
        delete "/companies/#{company.id}", headers: auth_headers_with_token
      end.to change(Company, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      delete "/companies/#{company.id}"

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns not found when company doesn't exist" do
      delete '/companies/0', headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end
end
