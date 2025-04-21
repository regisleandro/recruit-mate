class WhatsAppBusinessConfigSerializer < ActiveModel::Serializer
  attributes :id, :phone_number_id, :business_account_id, :created_at, :updated_at

  # We don't include access_token and webhook_secret in the response
  # for security reasons

  belongs_to :recruiter
end
