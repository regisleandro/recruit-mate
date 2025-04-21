module RequestHelpers
  # Use this before making requests in tests to stub authentication
  def stub_authentication(user)
    # Mock current_user and authenticate_user! for the controller
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)

    # Optionally generate a valid token for headers
    @auth_token = JWT.encode(
      { sub: user.id, jti: user.jti, exp: 2.hours.from_now.to_i },
      Rails.application.credentials.secret_key_base || 'test_secret_key'
    )
  end

  # Generate auth headers with the stubbed token
  def auth_headers_with_token
    {
      'Authorization' => "Bearer #{@auth_token}",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end

  # Parse JSON response
  def json_response
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
