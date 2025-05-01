require 'rails_helper'

RSpec.describe 'Api::V1::Dashboard', type: :request do
  let(:user) { create(:user) }
  let(:company) { create(:company, user: user) }
  let!(:jobs) { create_list(:job, 3, company: company, status: 'open', user: user) }
  let!(:candidates) { create_list(:candidate, 3, user: user) }

  # Create job applications with different job-candidate pairings to avoid validation error
  let!(:job_applications) do
    [
      create(:job_application, job: jobs[0], candidate: candidates[0], user: user),
      create(:job_application, job: jobs[1], candidate: candidates[0], user: user),
      create(:job_application, job: jobs[0], candidate: candidates[1], user: user)
    ]
  end

  describe 'GET /api/v1/dashboard' do
    context 'when authenticated' do
      before do
        # Authenticate the user using the helper method
        stub_authentication(user)
        get '/api/v1/dashboard', headers: auth_headers_with_token
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:success)
      end

      it 'returns dashboard stats with correct values' do
        json_response = response.parsed_body
        expect(json_response['stats']).to include(
          'jobs_opened' => jobs.count,
          'applications' => job_applications.count
        )
      end

      it 'contains activity structure with required sections' do
        json_response = response.parsed_body
        expect(json_response['recent_activity']).to include(
          'new_jobs',
          'new_candidates',
          'new_applications'
        )
      end

      it 'includes jobs data in the activity section' do
        json_response = response.parsed_body
        expect(json_response['recent_activity']['new_jobs'].length).to be > 0
        expect(json_response['recent_activity']['new_jobs'].first).to include(
          'id',
          'title',
          'company_name',
          'created_at'
        )
      end

      it 'includes candidates data in the activity section' do
        json_response = response.parsed_body
        expect(json_response['recent_activity']['new_candidates'].length).to be > 0
        expect(json_response['recent_activity']['new_candidates'].first).to include(
          'id',
          'name',
          'created_at'
        )
      end

      it 'includes applications data in the activity section' do
        json_response = response.parsed_body
        expect(json_response['recent_activity']['new_applications'].length).to be > 0
        expect(json_response['recent_activity']['new_applications'].first).to include(
          'id',
          'candidate_name',
          'job_title',
          'company_name',
          'status',
          'created_at'
        )
      end
    end

    context 'when not authenticated' do
      before do
        # Reset the authentication stub
        allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
        get '/api/v1/dashboard'
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
