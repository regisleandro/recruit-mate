require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  let(:user) { create(:user) }
  let!(:company) { create(:company, user: user) }
  let(:valid_attributes) { { name: 'Test Company' } }
  let(:invalid_attributes) { { name: '' } }

  before do
    # Mock authentication since we're testing at the controller level
    allow(controller).to receive_messages(authenticate_user!: true, current_user: user)
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'returns all companies in JSON format' do
      get :index
      json_response = response.parsed_body
      expect(json_response['data'].length).to eq(1)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: company.id }
      expect(response).to be_successful
    end

    it 'returns the company details in JSON format' do
      get :show, params: { id: company.id }
      json_response = response.parsed_body
      expect(json_response['data']['attributes']['name']).to eq(company.name)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Company' do
        expect do
          post :create, params: { company: valid_attributes }
        end.to change(Company, :count).by(1)
      end

      it 'renders a JSON response with the new company' do
        post :create, params: { company: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to include('application/json')
      end

      it 'associates the new company with the current user' do
        post :create, params: { company: valid_attributes }
        expect(Company.last.user).to eq(user)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Company' do
        expect do
          post :create, params: { company: invalid_attributes }
        end.not_to change(Company, :count)
      end

      it 'renders a JSON response with errors' do
        post :create, params: { company: invalid_attributes }
        expect(response).to have_http_status(422)
        expect(response.content_type).to include('application/json')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { name: 'Updated Company' } }

      it 'updates the requested company' do
        put :update, params: { id: company.id, company: new_attributes }
        company.reload
        expect(company.name).to eq('Updated Company')
      end

      it 'renders a JSON response with the updated company' do
        put :update, params: { id: company.id, company: new_attributes }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('application/json')
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors' do
        put :update, params: { id: company.id, company: invalid_attributes }
        expect(response).to have_http_status(422)
        expect(response.content_type).to include('application/json')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested company' do
      expect do
        delete :destroy, params: { id: company.id }
      end.to change(Company, :count).by(-1)
    end

    it 'returns a no_content status' do
      delete :destroy, params: { id: company.id }
      expect(response).to have_http_status(:no_content)
    end
  end
end
