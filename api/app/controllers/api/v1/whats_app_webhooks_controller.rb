module Api
  module V1
    class WhatsAppWebhooksController < ApplicationController
      skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

      # GET /api/v1/whatsapp_webhooks
      # For webhook verification by WhatsApp
      def verify
        # WhatsApp webhook verification
        mode = params['hub.mode']
        token = params['hub.verify_token']
        challenge = params['hub.challenge']

        # Verify token (should match your environmental configuration)
        verification_token = ENV.fetch('WHATSAPP_WEBHOOK_VERIFY_TOKEN', 'your_default_token')

        if mode == 'subscribe' && token == verification_token
          render plain: challenge, status: :ok
        else
          head :forbidden
        end
      end

      # POST /api/v1/whatsapp_webhooks
      # Webhook for receiving WhatsApp messages and events
      def receive
        request_body = request.raw_post
        signature = request.headers['X-Hub-Signature-256']

        whats_app_config = WhatsAppBusinessConfig.first
        return head :not_found if whats_app_config.blank?

        whats_app_service = WhatsAppService.new(whats_app_config)

        if whats_app_service.verify_webhook_signature(signature, request_body)
          process_verified_webhook(request_body)
        else
          handle_invalid_signature
        end
      rescue JSON::ParserError => e
        handle_parse_error(e)
      end

      private

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

      def process_webhook_data(data)
        Rails.logger.info("Processing webhook data: #{data.to_json}")

        entry = data[:entry]&.first
        return unless entry

        changes = entry[:changes]&.first
        return unless changes

        value = changes[:value]
        return unless value

        process_messages(value[:messages]) if value[:messages].present?
      end

      def process_messages(messages)
        messages.each do |message|
          Rails.logger.info("Received WhatsApp message: #{message.inspect}")

          # Only process text messages
          next unless message[:type] == 'text'

          # Get the sender phone number and text content
          # These variables will be used when uncommenting the job below
          # from = message[:from]
          # text = message[:text][:body]

          # You could trigger a background job to process the message
          # ProcessWhatsAppMessageJob.perform_later(from, text)
        end
      end
    end
  end
end
