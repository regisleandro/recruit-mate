require 'rails_helper'

RSpec.describe 'Jobs API', type: :request do
  let(:user) { create(:user) }
  let(:company) { create(:company, user: user) }
  let(:job) { create(:job, company: company) }
  let(:valid_attributes) do
    {
      description: 'Senior Ruby Developer',
      benefits: 'Health insurance, 401k, free lunch',
      keywords: 'ruby,rails,api',
      start_time: Time.current,
      end_time: 30.days.from_now,
      interval_time: 30,
      status: 'open',
      prompt: 'Looking for a senior Ruby developer with Rails experience',
      company_id: company.id
    }
  end
  let(:invalid_attributes) { { description: '', status: 'draft' } }

  before do
    stub_authentication(user)
  end

  describe 'GET /jobs' do
    it 'returns a list of all jobs when authenticated' do
      create_list(:job, 3)

      get '/jobs', headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(3)
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      get '/jobs'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /companies/:company_id/jobs' do
    it 'returns jobs for a specific company' do
      create_list(:job, 3, company: company)
      other_company = create(:company, user: user)
      create_list(:job, 2, company: other_company)

      get "/companies/#{company.id}/jobs", headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(3)
    end
  end

  describe 'GET /jobs/:id' do
    it 'returns the requested job' do
      get "/jobs/#{job.id}", headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(job.id.to_s)
      expect(json_response['data']['attributes']['description']).to eq(job.description)
    end

    it 'returns not found when job does not exist' do
      get '/jobs/0', headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /jobs' do
    it 'creates a new job' do
      expect do
        post '/jobs', params: { job: valid_attributes }.to_json, headers: auth_headers_with_token
      end.to change(Job, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it 'does not create a job with invalid attributes' do
      expect do
        post '/jobs', params: { job: invalid_attributes }.to_json, headers: auth_headers_with_token
      end.not_to change(Job, :count)

      expect(response).to have_http_status(422)
    end
  end

  describe 'PATCH /jobs/:id' do
    it 'updates the job' do
      patch "/jobs/#{job.id}",
            params: { job: { description: 'Updated description' } }.to_json,
            headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      job.reload
      expect(job.description).to eq('Updated description')
    end
  end

  describe 'DELETE /jobs/:id' do
    it 'deletes the job' do
      job_to_delete = create(:job, company: company)

      expect do
        delete "/jobs/#{job_to_delete.id}", headers: auth_headers_with_token
      end.to change(Job, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
