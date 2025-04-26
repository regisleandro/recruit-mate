class RecruiterSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :prompt

  attribute :openai_key do |object|
    if object.openai_key.present?
      # Extract the first 5 characters and last 4 characters of the key
      prefix = object.openai_key.to_s[0..4]
      suffix = object.openai_key.to_s[-4..]
      # Mask the middle part with "x" characters
      "#{prefix}#{'x' * (object.openai_key.to_s.length - 9)}#{suffix}"
    end
  end
end
