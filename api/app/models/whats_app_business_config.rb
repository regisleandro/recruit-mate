class WhatsAppBusinessConfig < ApplicationRecord
  belongs_to :recruiter
  belongs_to :user

  # Encrypt sensitive WhatsApp Business API credentials
  encrypts :access_token
  encrypts :phone_number_id, deterministic: true
  encrypts :business_account_id, deterministic: true
  encrypts :verify_token, deterministic: true

  # Validations
  validates :access_token, presence: true
  validates :phone_number_id, presence: true
  validates :business_account_id, presence: true
  validates :verify_token, presence: true, on: :update

  # Scopes
  scope :by_user, ->(user) { where(user_id: user.id) }

  # Generate a random verify token before saving if none exists
  before_save :ensure_verify_token

  # Adding a method to mask sensitive information in logs
  def to_s
    "#<WhatsAppBusinessConfig id: #{id}, recruiter_id: #{recruiter_id}>"
  end

  private

  def ensure_verify_token
    self.verify_token ||= SecureRandom.hex(32)
  end
end
