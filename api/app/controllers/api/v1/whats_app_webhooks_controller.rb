module Api
  module V1
    class WhatsAppWebhooksController < ApplicationController
      # GET /api/v1/whatsapp_webhooks
      # For webhook verification by WhatsApp
      def verify
        # WhatsApp webhook verification
        mode = params['hub.mode']
        token = params['hub.verify_token']
        challenge = params['hub.challenge']
        
        Rails.logger.info("WhatsApp webhook verification - Mode: #{mode}, Token present: #{token.present?}")
        
        # Check if the token matches a verify_token in any WhatsApp business configuration
        if mode == 'subscribe' && verify_token_valid?(token)
          Rails.logger.info("Token verification successful - Responding with challenge")
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
        
        # Parse the webhook data
        begin
          webhook_data = JSON.parse(request_body).with_indifferent_access
          
          # Validate webhook by checking for required WhatsApp-specific fields
          if valid_whatsapp_webhook_format?(webhook_data)
            # Extract phone_number_id and find the config
            phone_number_id = webhook_data.dig(:entry, 0, :changes, 0, :value, :metadata, :phone_number_id)
            whats_app_config = find_config_by_phone_number_id(phone_number_id)
            
            if whats_app_config.present?
              # Process the webhook data
              process_verified_webhook(request_body)
            else
              Rails.logger.warn("No matching WhatsApp config found for phone_number_id: #{phone_number_id}")
              head :not_found
            end
          else
            Rails.logger.warn("Invalid WhatsApp webhook format")
            head :bad_request
          end
        rescue JSON::ParserError => e
          handle_parse_error(e)
        end
      end

      private
      
      def find_config_by_phone_number_id(phone_number_id)
        return nil if phone_number_id.blank?        
        config = WhatsAppBusinessConfig.find_by(phone_number_id: phone_number_id)
        config
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
        # Process the webhook data here
        # For now, we just log it
        
        # You can implement proper message handling here
        # Example: process incoming message from a candidate
        # handle_incoming_message(webhook_data)
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
        
        legacy_valid = WhatsAppBusinessConfig.exists?(webhook_secret: token)
        
        legacy_valid
      end

      # Alternative validation approach that doesn't rely on signatures
      def valid_whatsapp_webhook_format?(data)
        # Check for required fields in the webhook data structure
        return false unless data.is_a?(Hash)
        return false unless data[:object] == "whatsapp_business_account"
        return false unless data[:entry].is_a?(Array) && data[:entry].any?
        
        # Check for required fields in the entry
        entry = data[:entry].first
        return false unless entry.is_a?(Hash) && entry[:id].present? && entry[:changes].is_a?(Array) && entry[:changes].any?
        
        # Check for required fields in the changes
        change = entry[:changes].first
        return false unless change.is_a?(Hash) && change[:field].present? && change[:value].is_a?(Hash)
        
        # If messages field is present, check for metadata
        if change[:field] == "messages"
          value = change[:value]
          return false unless value[:messaging_product] == "whatsapp"
          return false unless value[:metadata].is_a?(Hash) && value[:metadata][:phone_number_id].present?
        end
        
        true
      end
    end
  end
end
