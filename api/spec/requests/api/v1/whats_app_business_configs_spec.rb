require 'rails_helper'

RSpec.describe 'Api::V1::WhatsAppBusinessConfigs', type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers_with_token.merge({ 'Content-Type' => 'application/json' }) }
  let(:whats_app_config_params) do
    {
      whats_app_business_config: {
        access_token: 'test_access_token',
        phone_number_id: 'test_phone_number_id',
        business_account_id: 'test_business_account_id',
        verify_token: 'test_verify_token'
      }
    }.to_json
  end
  let(:recruiter) { create(:recruiter, user: user) }

  before do
    stub_authentication(user)
  end

  describe 'GET /api/v1/recruiters/:recruiter_id/whatsapp_business_config' do
    context 'when config exists' do
      let(:whats_app_config) { create(:whats_app_business_config, recruiter: recruiter, user: user) }

      it 'returns the config' do
        whats_app_config

        get "/api/v1/recruiters/#{recruiter.id}/whatsapp_business_config", headers: headers
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['data']).to include('id')
      end
    end

    context 'when config does not exist' do
      it 'returns not found' do
        get "/api/v1/recruiters/#{recruiter.id}/whatsapp_business_config", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/recruiters/:recruiter_id/whatsapp_business_config' do
    context 'with valid parameters' do
      it 'creates a new WhatsApp Business config' do
        post "/api/v1/recruiters/#{recruiter.id}/whatsapp_business_config",
             params: whats_app_config_params,
             headers: headers

        puts "Response Status: #{response.status}"
        puts "Response Body: #{response.body}"

        expect(response.status).to eq(201)
        expect(WhatsAppBusinessConfig.count).to eq(1)
      end
    end

    context 'when config already exists' do
      let(:existing_config) { create(:whats_app_business_config, recruiter: recruiter, user: user) }

      it 'returns an error' do
        existing_config

        post "/api/v1/recruiters/#{recruiter.id}/whatsapp_business_config",
             params: whats_app_config_params,
             headers: headers

        expect(response).to have_http_status(422)
        expect(response.parsed_body).to have_key('error')
      end
    end
  end

  describe 'PUT /api/v1/recruiters/:recruiter_id/whatsapp_business_config' do
    let(:whats_app_config) { create(:whats_app_business_config, recruiter: recruiter, user: user) }

    before do
      whats_app_config
    end

    context 'with valid parameters' do
      it 'updates the config' do
        update_params = {
          whats_app_business_config: {
            access_token: 'updated_token'
          }
        }.to_json

        put "/api/v1/recruiters/#{recruiter.id}/whatsapp_business_config",
            params: update_params,
            headers: headers

        expect(response).to have_http_status(:ok)
        whats_app_config.reload
        expect(whats_app_config.access_token).to eq('updated_token')
      end
    end
  end

  describe 'DELETE /api/v1/recruiters/:recruiter_id/whatsapp_business_config' do
    let(:whats_app_config) { create(:whats_app_business_config, recruiter: recruiter, user: user) }

    before do
      whats_app_config
    end

    it 'deletes the config' do
      expect do
        delete "/api/v1/recruiters/#{recruiter.id}/whatsapp_business_config", headers: headers
      end.to change(WhatsAppBusinessConfig, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'POST /api/v1/recruiters/:recruiter_id/whatsapp_business_config/test_message' do
    let(:whats_app_config) { create(:whats_app_business_config, recruiter: recruiter, user: user) }
    let(:whats_app_service) { instance_double(WhatsAppService) }
    let(:phone_number) { '+1234567890' }
    let(:message) { 'Test message' }

    before do
      whats_app_config
      allow(WhatsAppService).to receive(:new).and_return(whats_app_service)
    end

    context 'with valid parameters' do
      it 'sends a test message successfully' do
        allow(whats_app_service).to receive(:send_text_message).and_return({
                                                                             'messages' => [{ 'id' => 'message_id_123' }]
                                                                           })

        test_params = { phone_number: phone_number, message: message }.to_json

        post "/api/v1/recruiters/#{recruiter.id}/whatsapp_business_config/test_message",
             params: test_params,
             headers: headers

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include(
          'success' => true,
          'message' => 'Test message sent successfully',
          'message_id' => 'message_id_123'
        )
      end
    end

    context 'when WhatsApp config is not found' do
      it 'returns a not found error' do
        delete "/api/v1/recruiters/#{recruiter.id}/whatsapp_business_config", headers: headers

        test_params = { phone_number: phone_number, message: message }.to_json

        post "/api/v1/recruiters/#{recruiter.id}/whatsapp_business_config/test_message",
             params: test_params,
             headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when parameters are missing' do
      it 'returns unprocessable entity for missing phone number' do
        test_params = { message: message }.to_json

        post "/api/v1/recruiters/#{recruiter.id}/whatsapp_business_config/test_message",
             params: test_params,
             headers: headers

        expect(response).to have_http_status(422)
      end

      it 'returns unprocessable entity for missing message' do
        test_params = { phone_number: phone_number }.to_json

        post "/api/v1/recruiters/#{recruiter.id}/whatsapp_business_config/test_message",
             params: test_params,
             headers: headers

        expect(response).to have_http_status(422)
      end
    end

    context 'when WhatsApp API returns an error' do
      it 'handles the error properly' do
        allow(whats_app_service).to receive(:send_text_message).and_return({
                                                                             error: 'API Error',
                                                                             details: 'Something went wrong'
                                                                           })

        test_params = { phone_number: phone_number, message: message }.to_json

        post "/api/v1/recruiters/#{recruiter.id}/whatsapp_business_config/test_message",
             params: test_params,
             headers: headers

        expect(response).to have_http_status(422)
        expect(response.parsed_body).to include(
          'error' => 'API Error',
          'details' => 'Something went wrong'
        )
      end
    end
  end
end
