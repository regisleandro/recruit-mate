class WhatsAppService
  require 'base64'
  include HTTParty
  attr_reader :config

  def initialize(config)
    @config = config
    self.class.base_uri 'https://graph.facebook.com/v22.0'
  end

  # Send a text message to a phone number
  def send_text_message(to, message)
    endpoint = "/#{config.phone_number_id}/messages"

    options = {
      headers: {
        'Authorization' => "Bearer #{config.access_token}",
        'Content-Type' => 'application/json'
      },
      body: {
        messaging_product: 'whatsapp',
        recipient_type: 'individual',
        to: to,
        type: 'text',
        text: {
          body: message
        }
      }.to_json
    }

    response = self.class.post(endpoint, options)
    handle_response(response)
  end

  # Verify webhook using verify token (hub.verify_token) method
  def verify_webhook_token(mode, token, challenge)
    # Check if this is a verification request
    return nil unless mode == 'subscribe'

    # Log the verification attempt
    Rails.logger.info('Verifying webhook token')
    Rails.logger.info("Received token: #{token}")
    Rails.logger.info("Expected token: #{config.verify_token}")

    # Verify that the token matches your configured token
    if token == config.verify_token
      Rails.logger.info('Token verified successfully, responding with challenge')
      challenge
    else
      Rails.logger.warn('Token verification failed')
      nil
    end
  end

  # Get business profile information
  def business_profile
    endpoint = "/#{config.phone_number_id}/whatsapp_business_profile"

    options = {
      headers: {
        'Authorization' => "Bearer #{config.access_token}"
      },
      query: {
        fields: 'about,address,description,email,profile_picture_url,websites'
      }
    }

    response = self.class.get(endpoint, options)
    handle_response(response)
  end

  private

  def handle_response(response)
    if response.success?
      response.parsed_response
    else
      error_message = "WhatsApp API Error: #{response.code} - #{response.message}"
      Rails.logger.error(error_message)
      { error: error_message, details: response.parsed_response }
    end
  rescue StandardError => e
    Rails.logger.error("WhatsApp API Error: #{e.message}")
    { error: e.message }
  end
end
