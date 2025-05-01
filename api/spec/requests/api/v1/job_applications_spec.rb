require 'rails_helper'

RSpec.describe 'API V1 Job Applications', type: :request do
  let(:user) { create(:user) }
  let(:company) { create(:company, user: user) }
  let(:job) { create(:job, company: company, user: user) }
  let(:candidate) { create(:candidate, user: user) }
  let(:job_application) { create(:job_application, job: job, candidate: candidate, user: user) }

  let(:valid_attributes) do
    {
      job_id: job.id,
      candidate_id: candidate.id,
      status: 'pending',
      notes: 'Application notes'
    }
  end

  let(:invalid_attributes) { { job_id: nil, candidate_id: nil } }

  before do
    stub_authentication(user)
  end

  describe 'GET /api/v1/job_applications' do
    it 'returns a list of job applications when authenticated' do
      # Create a job application with the existing job and candidate
      create(:job_application, job: job, candidate: candidate, user: user)

      # Create additional job applications with unique job/candidate combinations
      2.times do
        new_job = create(:job, company: company, user: user)
        new_candidate = create(:candidate, user: user)
        create(:job_application, job: new_job, candidate: new_candidate, user: user)
      end

      get '/api/v1/job_applications', headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(3)
    end

    it 'returns unauthorized when not authenticated' do
      # Reset the authentication stub
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
      get '/api/v1/job_applications'

      expect(response).to have_http_status(:unauthorized)
    end

    it 'filters by job_id' do
      # Create a job application with the existing job and candidate
      create(:job_application, job: job, candidate: candidate, user: user)

      # Create two more job applications with the same job but different candidates
      2.times do
        new_candidate = create(:candidate, user: user)
        create(:job_application, job: job, candidate: new_candidate, user: user)
      end

      # Create job applications for a different job
      another_job = create(:job, company: company, user: user)
      2.times do
        new_candidate = create(:candidate, user: user)
        create(:job_application, job: another_job, candidate: new_candidate, user: user)
      end

      get "/api/v1/job_applications?job_id=#{job.id}", headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(3)
    end

    it 'filters by candidate_id' do
      # Create a job application with the existing job and candidate
      create(:job_application, job: job, candidate: candidate, user: user)

      # Create two more job applications with the same candidate but different jobs
      2.times do
        new_job = create(:job, company: company, user: user)
        create(:job_application, job: new_job, candidate: candidate, user: user)
      end

      # Create job applications for a different candidate
      another_candidate = create(:candidate, user: user)
      2.times do
        new_job = create(:job, company: company, user: user)
        create(:job_application, job: new_job, candidate: another_candidate, user: user)
      end

      get "/api/v1/job_applications?candidate_id=#{candidate.id}", headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(3)
    end

    it 'filters by status' do
      # Create pending applications
      2.times do
        new_job = create(:job, company: company, user: user)
        new_candidate = create(:candidate, user: user)
        create(:job_application, job: new_job, candidate: new_candidate, status: :pending, user: user)
      end

      # Create a rejected application
      new_job = create(:job, company: company, user: user)
      new_candidate = create(:candidate, user: user)
      create(:job_application, job: new_job, candidate: new_candidate, status: :rejected, user: user)

      get '/api/v1/job_applications?status=pending', headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(2)
    end
  end

  describe 'GET /api/v1/jobs/:job_id/job_applications' do
    it 'returns job applications for a specific job' do
      # Create a job application with the existing job and candidate
      create(:job_application, job: job, candidate: candidate, user: user)

      # Create two more job applications with the same job but different candidates
      2.times do
        new_candidate = create(:candidate, user: user)
        create(:job_application, job: job, candidate: new_candidate, user: user)
      end

      # Create job applications for a different job
      another_job = create(:job, company: company, user: user)
      2.times do
        new_candidate = create(:candidate, user: user)
        create(:job_application, job: another_job, candidate: new_candidate, user: user)
      end

      get "/api/v1/jobs/#{job.id}/job_applications", headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(3)
    end
  end

  describe 'GET /api/v1/job_applications/:id' do
    it 'returns the requested job application when authenticated' do
      get "/api/v1/job_applications/#{job_application.id}", headers: auth_headers_with_token

      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(job_application.id.to_s)
      expect(json_response['included']).to be_present
    end

    it "returns not found when job application doesn't exist" do
      get '/api/v1/job_applications/0', headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/job_applications' do
    context 'with valid parameters' do
      it 'creates a new job application' do
        expect do
          post '/api/v1/job_applications', params: { job_application: valid_attributes }.to_json, headers: auth_headers_with_token
        end.to change(JobApplication, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new job application' do
        expect do
          post '/api/v1/job_applications', params: { job_application: invalid_attributes }.to_json, headers: auth_headers_with_token
        end.not_to change(JobApplication, :count)

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PATCH /api/v1/job_applications/:id' do
    context 'with valid parameters' do
      let(:new_attributes) { { status: 'interviewing', notes: 'Updated notes' } }

      it 'updates the requested job application' do
        patch "/api/v1/job_applications/#{job_application.id}", params: { job_application: new_attributes }.to_json, headers: auth_headers_with_token
        job_application.reload

        expect(response).to have_http_status(:ok)
        expect(job_application.status).to eq('interviewing')
        expect(job_application.notes).to eq('Updated notes')
      end
    end

    context 'with invalid parameters' do
      it "renders errors and doesn't update the job application" do
        patch "/api/v1/job_applications/#{job_application.id}", params: { job_application: invalid_attributes }.to_json, headers: auth_headers_with_token

        expect(response).to have_http_status(422)
      end
    end

    it "returns not found when job application doesn't exist" do
      patch '/api/v1/job_applications/0', params: { job_application: { status: 'interviewing' } }.to_json, headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/job_applications/:id' do
    it 'destroys the requested job application' do
      job_application # create job application first

      expect do
        delete "/api/v1/job_applications/#{job_application.id}", headers: auth_headers_with_token
      end.to change(JobApplication, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns not found when job application doesn't exist" do
      delete '/api/v1/job_applications/0', headers: auth_headers_with_token

      expect(response).to have_http_status(:not_found)
    end
  end
end
