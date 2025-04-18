require 'rails_helper'

RSpec.describe 'Candidates', type: :request do
  let(:user) { create(:user) }
  let!(:candidate) { create(:candidate, user: user) }
  let(:headers) do
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end

  before do
    stub_authentication(user)
  end

  describe 'GET /candidates' do
    context 'when authenticated' do
      it 'returns a list of candidates for the current user' do
        get '/candidates', headers: auth_headers_with_token

        expect(response).to have_http_status(:success)
        expect(json_response['data'].size).to eq(1)
        expect(json_response['data'][0]['attributes']['name']).to eq(candidate.name)
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        # Reset the authentication stub
        allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
        get '/candidates', headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /candidates/:id' do
    context 'when authenticated' do
      it 'returns the candidate' do
        get "/candidates/#{candidate.id}", headers: auth_headers_with_token

        expect(response).to have_http_status(:success)
        expect(json_response['data']['attributes']['name']).to eq(candidate.name)
      end

      it "returns not found for another user's candidate" do
        other_user = create(:user)
        other_candidate = create(:candidate, user: other_user)

        get "/candidates/#{other_candidate.id}", headers: auth_headers_with_token

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /candidates' do
    let(:valid_attributes) do
      {
        candidate: {
          name: 'Test Candidate',
          cpf: '12345678901',
          cellphone_number: '1234567890',
          curriculum_summary: 'Test summary'
        }
      }
    end

    context 'when authenticated' do
      it 'creates a new candidate' do
        expect do
          post '/candidates', params: valid_attributes.to_json, headers: auth_headers_with_token
        end.to change(Candidate, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['data']['attributes']['name']).to eq('Test Candidate')
        expect(json_response['data']['attributes']['cpf']).to eq('12345678901')
      end

      it 'returns errors for invalid data' do
        post '/candidates', params: { candidate: { name: '' } }.to_json, headers: auth_headers_with_token

        expect(response).to have_http_status(422)
        expect(json_response['errors']).to be_present
      end
    end
  end

  describe 'PATCH /candidates/:id' do
    let(:update_attributes) do
      {
        candidate: {
          name: 'Updated Name',
          curriculum_summary: 'Updated summary'
        }
      }
    end

    context 'when authenticated' do
      it 'updates the candidate' do
        patch "/candidates/#{candidate.id}", params: update_attributes.to_json, headers: auth_headers_with_token

        expect(response).to have_http_status(:success)
        candidate.reload
        expect(candidate.name).to eq('Updated Name')
        expect(candidate.curriculum_summary).to eq('Updated summary')
      end

      it 'returns errors for invalid data' do
        patch "/candidates/#{candidate.id}", params: { candidate: { name: '' } }.to_json, headers: auth_headers_with_token

        expect(response).to have_http_status(422)
        expect(json_response['errors']).to be_present
      end
    end
  end

  describe 'DELETE /candidates/:id' do
    context 'when authenticated' do
      it 'deletes the candidate' do
        expect do
          delete "/candidates/#{candidate.id}", headers: auth_headers_with_token
        end.to change(Candidate, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
