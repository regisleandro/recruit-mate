class WhatsAppBusinessConfigSerializer
  include JSONAPI::Serializer

  attributes :id, :phone_number_id, :business_account_id, :created_at, :updated_at

  belongs_to :recruiter
end
