module Api
  module V1
    class WhatsAppBusinessConfigsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_whats_app_config, only: %i[show update destroy test_message]
      before_action :ensure_recruiter_exists, only: %i[create update destroy test_message]

      # GET /api/v1/whatsapp_business_config/:recruiter_id
      def show
        if @whats_app_config
          render json: @whats_app_config, status: :ok
        else
          render json: { error: 'WhatsApp Business configuration not found' }, status: :not_found
        end
      end

      # POST /api/v1/whatsapp_business_config/:recruiter_id
      def create
        # Check if config already exists
        recruiter = Recruiter.find(params[:recruiter_id])
        if recruiter.whats_app_business_config.present?
          return render json: { error: 'WhatsApp Business configuration already exists' }, status: :unprocessable_entity
        end

        @whats_app_config = current_user.whats_app_business_configs.new(whats_app_config_params)
        @whats_app_config.recruiter = recruiter

        if @whats_app_config.save
          render json: @whats_app_config, status: :created
        else
          render json: { errors: @whats_app_config.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PUT/PATCH /api/v1/whatsapp_business_config/:recruiter_id
      def update
        if @whats_app_config.update(whats_app_config_params)
          render json: @whats_app_config, status: :ok
        else
          render json: { errors: @whats_app_config.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/whatsapp_business_config/:recruiter_id
      def destroy
        if @whats_app_config.destroy
          head :no_content
        else
          render json: { error: 'Failed to delete WhatsApp Business configuration' }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/whatsapp_business_config/:recruiter_id/test_message
      def test_message
        return render_not_found unless @whats_app_config
        return render_missing_params unless valid_message_params?

        formatted_phone = format_phone_number(params[:phone_number])
        send_test_message(formatted_phone, params[:message])
      end

      private

      def render_not_found
        render json: { error: 'WhatsApp Business configuration not found' }, status: :not_found
      end

      def render_missing_params
        render json: { error: 'Phone number and message are required' }, status: :unprocessable_entity
      end

      def valid_message_params?
        params[:phone_number].present? && params[:message].present?
      end

      def send_test_message(phone, message)
        whats_app_service = WhatsAppService.new(@whats_app_config)
        result = whats_app_service.send_text_message(phone, message)

        if result[:error].present?
          render json: { error: result[:error], details: result[:details] }, status: :unprocessable_entity
        else
          render json: {
            success: true,
            message: 'Test message sent successfully',
            message_id: result['messages']&.first&.dig('id')
          }, status: :ok
        end
      end

      def set_whats_app_config
        @whats_app_config = WhatsAppBusinessConfig.by_user(current_user).find_by(recruiter_id: params[:recruiter_id])
      end

      def ensure_recruiter_exists
        unless Recruiter.exists?(params[:recruiter_id])
          render json: { error: 'Recruiter not found' }, status: :not_found
        end
      end

      def whats_app_config_params
        params.require(:whats_app_business_config).permit(
          :access_token,
          :phone_number_id,
          :business_account_id,
          :verify_token
        )
      end

      def format_phone_number(phone)
        # Remove all non-digit characters
        digits = phone.gsub(/\D/, '')

        # Ensure it starts with a + (WhatsApp requires this)
        return "+#{digits}" unless digits.start_with?('+')

        phone
      end
    end
  end
end
