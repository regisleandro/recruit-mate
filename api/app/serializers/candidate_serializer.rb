class CandidateSerializer
  include JSONAPI::Serializer

  attributes :id, :name, :curriculum_summary, :cellphone_number, :cpf, :created_at, :updated_at

  attribute :curriculum_url, &:curriculum_url

  belongs_to :user
end
