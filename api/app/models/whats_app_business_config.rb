class WhatsAppBusinessConfig < ApplicationRecord
  belongs_to :recruiter

  # Encrypt sensitive WhatsApp Business API credentials
  encrypts :access_token
  encrypts :phone_number_id
  encrypts :business_account_id
  encrypts :webhook_secret

  # Validations
  validates :access_token, presence: true
  validates :phone_number_id, presence: true
  validates :business_account_id, presence: true
  validates :webhook_secret, presence: true

  # Adding a method to mask sensitive information in logs
  def to_s
    "#<WhatsAppBusinessConfig id: #{id}, recruiter_id: #{recruiter_id}>"
  end
end
