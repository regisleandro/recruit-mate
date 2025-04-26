require 'aws-sdk-s3'

# Configure AWS credentials
if Rails.application.credentials.dig(:aws, :access_key_id).present?
  # Get AWS configuration from credentials
  bucket_name = Rails.application.credentials.dig(:aws, :bucket) || "recruit-mate-app-#{Rails.env}"
  region = Rails.application.credentials.dig(:aws, :region) || 'sa-east-1'  # Updated to sa-east-1 as per the error message
  
  # Configure AWS SDK with the region
  Aws.config.update({
    region: region,
    credentials: Aws::Credentials.new(
      Rails.application.credentials.dig(:aws, :access_key_id),
      Rails.application.credentials.dig(:aws, :secret_access_key)
    )
  })
  
  # The public URL format for S3 objects
  # https://bucket-name.s3.region.amazonaws.com/
  Rails.application.config.aws_bucket_url = "https://#{bucket_name}.s3.#{region}.amazonaws.com"
  
  # Log AWS configuration in development mode
  if Rails.env.development?
    Rails.logger.info("AWS bucket configured: #{bucket_name}")
    Rails.logger.info("AWS region configured: #{region}")
    Rails.logger.info("AWS bucket URL: #{Rails.application.config.aws_bucket_url}")
  end
else
  Rails.logger.warn("AWS credentials not found. File storage features may not work correctly.")
end 