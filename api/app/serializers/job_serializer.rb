class JobSerializer
  include JSONAPI::Serializer

  attributes :id, :description, :benefits, :keywords, :start_time,
             :end_time, :interval_time, :status, :prompt, :created_at, :updated_at

  attribute :company_id

  attribute :status_label do |object|
    object.status.humanize
  end

  belongs_to :company
end
