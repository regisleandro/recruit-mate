class JobApplicationSerializer
  include JSONAPI::Serializer

  attributes :id, :status, :notes, :created_at, :updated_at

  attribute :candidate_id
  attribute :job_id

  belongs_to :candidate
  belongs_to :job
end
