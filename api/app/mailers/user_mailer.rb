class UserMailer < ApplicationMailer
  default from: 'no-reply@recruit-mate.example.com'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.confirmation_instructions.subject
  #
  def confirmation_instructions(user, token, options = {})
    @user = user
    @token = token
    @confirmation_url = "#{frontend_url}/auth/confirm?confirmation_token=#{token}"
    
    # Log the token in development for easier testing
    if Rails.env.development?
      Rails.logger.info "Development confirmation URL: #{@confirmation_url}"
    end
    
    mail(
      to: user.email,
      subject: 'Confirm your RecruitMate account'
    )
  end
  
  private
  
  def frontend_url
    Rails.env.production? ? 
      'https://your-production-url.com' : 
      'http://localhost:5173' # Default Vite dev server port
  end
end
