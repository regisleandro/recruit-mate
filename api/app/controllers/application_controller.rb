class ApplicationController < ActionController::API
  include RackSessionsFix
  before_action :configure_permitted_parameters, if: :devise_controller?

  def authenticate_user!
    handle_missing_token && return if request.headers['Authorization'].blank?

    handle_token_verification
  rescue ActiveRecord::RecordNotFound
    render_unauthorized('User not found')
  end

  def current_user
    @current_user ||= User.find(@current_user_id) if @current_user_id
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name avatar])
  end

  private

  def handle_missing_token
    render_unauthorized('You need to sign in or sign up before continuing.')
  end

  def handle_token_verification
    begin
      jwt_payload = JWT.decode(
        request.headers['Authorization'].split.last,
        Rails.application.credentials.devise_jwt_secret_key!
      ).first
      @current_user_id = jwt_payload['sub']
    rescue JWT::DecodeError
      render_unauthorized('Invalid or expired token')
      return
    end

    @current_user = User.find(@current_user_id)
  end

  def render_unauthorized(message)
    render json: { status: 401, error: message }, status: :unauthorized
  end
end
