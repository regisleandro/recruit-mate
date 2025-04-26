class Recruiter < ApplicationRecord
  belongs_to :user
  has_one :whats_app_business_config, dependent: :destroy

  # Encrypt sensitive OpenAI API key
  encrypts :openai_key

  validates :name, presence: true
end
