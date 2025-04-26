require 'rails_helper'

RSpec.describe 'API V1 Jobs', type: :request do
  let(:user) { create(:user) }
  let(:company) { create(:company, user: user) }
  let(:job) { create(:job, company: company) }
  let(:valid_attributes) do
    {
      title: 'Software Engineer',
      description: 'Test Job',
      company_id: company.id,
      benefits: 'Benefits',
      keywords: 'keywords',
      status: 'draft'
    }
  end
  let(:invalid_attributes) { { description: '', company_id: nil } }

  before do
    stub_authentication(user)
  end

  describe 'GET /api/v1/jobs' do
    it 'returns a list of jobs when authenticated' do
      create_list(:job, 3, company: company)

      get '/api/v1/jobs', headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(3)
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      get '/api/v1/jobs'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/companies/:company_id/jobs' do
    it 'returns jobs for a specific company' do
      create_list(:job, 3, company: company)
      another_company = create(:company, user: user)
      create_list(:job, 2, company: another_company)

      get "/api/v1/companies/#{company.id}/jobs", headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(3)
    end
  end

  describe 'GET /api/v1/jobs/:id' do
    it 'returns the requested job when authenticated' do
      get "/api/v1/jobs/#{job.id}", headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(job.id.to_s)
    end

    it "returns not found when job doesn't exist" do
      get '/api/v1/jobs/0', headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/jobs' do
    context 'with valid parameters' do
      it 'creates a new job' do
        expect do
          post '/api/v1/jobs', params: { job: valid_attributes }.to_json, headers: auth_headers_with_token
        end.to change(Job, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new job' do
        expect do
          post '/api/v1/jobs', params: { job: invalid_attributes }.to_json, headers: auth_headers_with_token
        end.not_to change(Job, :count)

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT /api/v1/jobs/:id' do
    context 'with valid parameters' do
      let(:new_attributes) { { description: 'Updated Job' } }

      it 'updates the requested job' do
        put "/api/v1/jobs/#{job.id}", params: { job: new_attributes }.to_json, headers: auth_headers_with_token
        job.reload

        expect(response).to have_http_status(:ok)
        expect(job.description).to eq('Updated Job')
      end
    end

    context 'with invalid parameters' do
      it "renders errors and doesn't update the job" do
        put "/api/v1/jobs/#{job.id}", params: { job: invalid_attributes }.to_json, headers: auth_headers_with_token

        expect(response).to have_http_status(422)
      end
    end

    it "returns not found when job doesn't exist" do
      put '/api/v1/jobs/0', params: { job: { description: 'Test' } }.to_json, headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/jobs/:id' do
    it 'destroys the requested job' do
      job # create job first

      expect do
        delete "/api/v1/jobs/#{job.id}", headers: auth_headers_with_token
      end.to change(Job, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns not found when job doesn't exist" do
      delete '/api/v1/jobs/0', headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end
end
