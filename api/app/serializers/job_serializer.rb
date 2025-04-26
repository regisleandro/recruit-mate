class JobSerializer
  include JSONAPI::Serializer

  attributes :id, :title, :description, :benefits, :keywords, :start_time,
             :end_time, :interval_time, :status, :prompt, :created_at, :updated_at

  attribute :company_id

  attribute :company do |object|
    if object.company
      {
        id: object.company.id,
        name: object.company.name
      }
    end
  end

  attribute :status_label do |object|
    object.status.humanize
  end

  belongs_to :company
end
