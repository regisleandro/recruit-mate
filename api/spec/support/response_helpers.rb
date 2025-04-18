module ResponseHelpers
  def json_response
    @json_response ||= response.parsed_body
  end
end

RSpec.configure do |config|
  config.include ResponseHelpers, type: :request
end
