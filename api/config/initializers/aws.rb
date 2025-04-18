require 'aws-sdk-s3'

# Configure AWS credentials
if Rails.application.credentials.dig(:aws, :access_key_id).present?
  # Configure the AWS bucket URL for easier access in the application
  bucket_name = Rails.application.credentials.dig(:aws, :bucket) || "recruit-mate-app-#{Rails.env}"
  region = Rails.application.credentials.dig(:aws, :region) || 'us-east-1'
  
  # The public URL format for S3 objects
  # https://bucket-name.s3.region.amazonaws.com/
  Rails.application.config.aws_bucket_url = "https://#{bucket_name}.s3.#{region}.amazonaws.com"
else
  Rails.logger.warn("AWS credentials not found. File storage features may not work correctly.")
end 