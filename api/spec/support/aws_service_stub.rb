RSpec.configure do |config|
  config.before do
    # Stub AWS service methods for tests
    allow(AwsService).to receive_messages(upload: true, delete: true, download: 'test file content',
                                          generate_presigned_url: 'https://test-bucket.s3.amazonaws.com/test-file.pdf')
  end
end
