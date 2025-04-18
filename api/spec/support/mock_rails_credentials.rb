RSpec.configure do |config|
  config.before do
    # Mock Rails.application.credentials to return a test secret key base
    allow(Rails.application.credentials)
      .to receive(:secret_key_base)
      .and_return('test_secret_key_base_for_jwt_testing')

    # Mock AWS credentials if needed
    allow(Rails.application.credentials)
      .to receive(:dig)
      .with(:aws, :access_key_id)
      .and_return('test_aws_access_key_id')

    allow(Rails.application.credentials)
      .to receive(:dig)
      .with(:aws, :secret_access_key)
      .and_return('test_aws_secret_access_key')

    allow(Rails.application.credentials)
      .to receive(:dig)
      .with(:aws, :region)
      .and_return('us-east-1')

    allow(Rails.application.credentials)
      .to receive(:dig)
      .with(:aws, :bucket)
      .and_return('test-bucket')
  end
end
