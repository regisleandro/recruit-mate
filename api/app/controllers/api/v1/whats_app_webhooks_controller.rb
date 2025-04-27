module Api
  module V1
    # rubocop:disable Metrics/ClassLength
    class WhatsAppWebhooksController < ApplicationController
      # GET /api/v1/whatsapp_webhooks
      # For webhook verification by WhatsApp
      def verify
        # WhatsApp webhook verification
        mode = params['hub.mode']
        token = params['hub.verify_token']
        challenge = params['hub.challenge']

        Rails.logger.info("WhatsApp webhook verification - Mode: #{mode}, Token present: #{token.present?}")

        if mode == 'subscribe' && verify_token_valid?(token)
          Rails.logger.info('Token verification successful - Responding with challenge')
          render plain: challenge, status: :ok
        else
          Rails.logger.warn("Token verification failed - Mode: #{mode}")
          head :forbidden
        end
      end

      # POST /api/v1/whatsapp_webhooks
      # Webhook for receiving WhatsApp messages and events
      def receive
        request.body.rewind
        request_body = request.body.read.force_encoding('ASCII-8BIT').dup
        begin
          webhook_data = parse_webhook_data(request_body)
          process_webhook(webhook_data, request_body)
        rescue JSON::ParserError => e
          handle_parse_error(e)
        end
      end

      private

      def parse_webhook_data(request_body)
        JSON.parse(request_body).with_indifferent_access
      end

      def process_webhook(webhook_data, request_body)
        if WhatsAppWebhookValidator.valid_format?(webhook_data)
          phone_number_id = extract_phone_number_id(webhook_data)
          process_valid_webhook(phone_number_id, request_body)
        else
          handle_invalid_webhook_format
        end
      end

      def extract_phone_number_id(webhook_data)
        webhook_data.dig(:entry, 0, :changes, 0, :value, :metadata, :phone_number_id)
      end

      def process_valid_webhook(phone_number_id, request_body)
        whats_app_config = find_config_by_phone_number_id(phone_number_id)

        if whats_app_config.present?
          process_verified_webhook(request_body)
        else
          log_no_matching_config(phone_number_id)
          head :not_found
        end
      end

      def log_no_matching_config(phone_number_id)
        Rails.logger.warn("No matching WhatsApp config found for phone_number_id: #{phone_number_id}")
      end

      def handle_invalid_webhook_format
        Rails.logger.warn('Invalid WhatsApp webhook format')
        head :bad_request
      end

      def find_config_by_phone_number_id(phone_number_id)
        return nil if phone_number_id.blank?

        WhatsAppBusinessConfig.find_by(phone_number_id: phone_number_id)
      end

      def process_verified_webhook(request_body)
        webhook_data = JSON.parse(request_body).with_indifferent_access
        process_webhook_data(webhook_data)
        head :ok
      end

      def handle_invalid_signature
        Rails.logger.warn('Invalid webhook signature received')
        head :forbidden
      end

      def handle_parse_error(error)
        Rails.logger.error("Error parsing webhook data: #{error.message}")
        head :bad_request
      end

      def process_webhook_data(webhook_data)
        messages = webhook_data.dig(:entry, 0, :changes, 0, :value, :messages)
        phone_number_id = webhook_data.dig(:entry, 0, :changes, 0, :value, :metadata, :phone_number_id)
        return if messages.blank?

        # Process only the first message in the webhook
        message = messages.first
        message_id = message[:id]

        message_cache_key = "whatsapp:message:#{message_id}"
        return if Rails.cache.exist?(message_cache_key)

        Rails.cache.write(message_cache_key, true, expires_in: 24.hours)

        config_cache_key = "whatsapp:config:#{phone_number_id}"
        whats_app_config = Rails.cache.fetch(config_cache_key, expires_in: 24.hours) do
          find_config_by_phone_number_id(phone_number_id)
        end

        return unless whats_app_config.present? && message[:type] == 'text'

        send_message(message, whats_app_config)
      end

      def send_message(message, whats_app_config)
        to = message_destinataire(message)

        Rails.logger.info("Processing message from #{to}")

        conversation_key = conversation_key(whats_app_config.phone_number_id, to)
        service = openai_service(whats_app_config, conversation_key)

        reply_message = service.chat(message: message.dig(:text, :body))

        Rails.cache.write(conversation_key, service, expires_in: 8.hours)

        whats_app_service = WhatsAppService.new(whats_app_config)

        Rails.logger.info("Sending response to #{to}")
        whats_app_service.send_text_message(to, reply_message[:content])
      end

      def message_destinataire(message)
        return message[:from] if message[:from].length > 12

        to = message[:from]
        "#{to[0..4]}9#{to[5..]}"
      end

      def conversation_key(phone_number_id, to)
        "whatsapp:conversation:#{phone_number_id}:#{to}"
      end

      def openai_service(whats_app_config, conversation_key)
        Rails.cache.fetch(conversation_key, expires_in: 8.hours) do
          OpenaiService.new(whats_app_config.recruiter.openai_key)
        end
      end

      # Verify token validation method
      def verify_token_valid?(token)
        return false if token.blank?

        exists = WhatsAppBusinessConfig.exists?(verify_token: token)
        Rails.logger.info("Checking if token matches any verify_token - Result: #{exists}")

        if !exists && !Rails.env.production?
          fallback_token = ENV.fetch('WHATSAPP_WEBHOOK_VERIFY_TOKEN', nil)
          match_fallback = fallback_token.present? && token == fallback_token
          Rails.logger.info("Fallback token check - Result: #{match_fallback}")
          return match_fallback
        end

        exists
      end

      def token_valid?(token)
        return true if verify_token_valid?(token)

        WhatsAppBusinessConfig.exists?(webhook_secret: token)
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
