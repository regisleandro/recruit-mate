module AuthHelpers
  def auth_headers(user)
    token = generate_jwt_token_for(user)
    { 'Authorization' => "Bearer #{token}" }
  end

  private

  def generate_jwt_token_for(user)
    JWT.encode(
      { sub: user.id, jti: user.jti, exp: 4.weeks.from_now.to_i },
      Rails.application.credentials.devise_jwt_secret_key!
    )
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
