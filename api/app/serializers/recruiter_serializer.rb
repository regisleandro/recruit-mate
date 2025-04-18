class RecruiterSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :prompt
end
