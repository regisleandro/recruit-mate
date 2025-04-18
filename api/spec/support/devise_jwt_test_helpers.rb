module DeviseJwtTestHelpers
  def auth_headers(headers_or_user, user = nil)
    # If the first parameter is a User object and no second parameter provided
    if headers_or_user.is_a?(User) && user.nil?
      user = headers_or_user
      headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
    else
      headers = headers_or_user
    end

    token = generate_jwt_token_for(user)
    headers.merge({
                    'Authorization' => "Bearer #{token}"
                  })
  end

  # Use this to stub JWT token verification
  def stub_auth_token(user)
    allow(JWT).to receive(:decode).and_return([{ 'sub' => user.id.to_s, 'jti' => user.jti }])
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
  end

  private

  def generate_jwt_token_for(user)
    JWT.encode(
      { sub: user.id, jti: user.jti, exp: 2.hours.from_now.to_i },
      Rails.application.credentials.secret_key_base || 'test_secret_key'
    )
  end
end
