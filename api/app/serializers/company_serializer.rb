class CompanySerializer
  include JSONAPI::Serializer
  attributes :id, :name
end
