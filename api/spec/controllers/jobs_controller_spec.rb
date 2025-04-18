require 'rails_helper'

RSpec.describe JobsController, type: :controller do
  let(:user) { create(:user) }
  let(:company) { create(:company, user: user) }
  let!(:job) { create(:job, company: company) }
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
  let(:invalid_attributes) { { description: '' } }

  before do
    allow(controller).to receive_messages(authenticate_user!: true, current_user: user)
  end

  describe 'GET #index' do
    it 'returns a success response with all jobs' do
      create_list(:job, 2)
      get :index
      expect(response).to be_successful
      expect(assigns(:jobs).count).to eq(3) # 1 existing + 2 created
    end

    it 'returns jobs for a specific company' do
      create_list(:job, 2, company: company)
      other_company = create(:company, user: user)
      create_list(:job, 2, company: other_company)

      get :index, params: { company_id: company.id }
      expect(response).to be_successful
      expect(assigns(:jobs).count).to eq(3) # 1 existing + 2 created for the company
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: job.id }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Job' do
        expect do
          post :create, params: { job: valid_attributes }
        end.to change(Job, :count).by(1)
      end

      it 'renders a JSON response with the new job' do
        post :create, params: { job: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to include('application/json')
      end

      it 'associates the job with the specified company' do
        post :create, params: { job: valid_attributes }
        expect(Job.last.company).to eq(company)
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors' do
        post :create, params: { job: invalid_attributes }
        expect(response).to have_http_status(422)
        expect(response.content_type).to include('application/json')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { description: 'Updated Job Description' } }

      it 'updates the requested job' do
        put :update, params: { id: job.id, job: new_attributes }
        job.reload
        expect(job.description).to eq('Updated Job Description')
      end

      it 'renders a JSON response with the updated job' do
        put :update, params: { id: job.id, job: new_attributes }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('application/json')
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors' do
        put :update, params: { id: job.id, job: invalid_attributes }
        expect(response).to have_http_status(422)
        expect(response.content_type).to include('application/json')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested job' do
      expect do
        delete :destroy, params: { id: job.id }
      end.to change(Job, :count).by(-1)
    end

    it 'returns a no content response' do
      delete :destroy, params: { id: job.id }
      expect(response).to have_http_status(:no_content)
    end
  end
end
