class WhatsAppService
  include HTTParty
  attr_reader :config

  def initialize(config)
    @config = config
    self.class.base_uri 'https://graph.facebook.com/v17.0'
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

  # Verify webhook signature
  def verify_webhook_signature(signature, body)
    return false if signature.blank? || config.webhook_secret.blank?

    # Use OpenSSL to verify HMAC SHA256 signature
    digest = OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'),
      config.webhook_secret,
      body
    )

    # Compare signatures in a secure way (constant-time comparison)
    ActiveSupport::SecurityUtils.secure_compare("sha256=#{digest}", signature)
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
