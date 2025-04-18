require 'aws-sdk-s3'

class AwsService
  class << self
    def upload(file_data, file_path)
      return false unless file_data.present? && file_path.present?

      begin
        s3 = aws_client
        bucket = aws_bucket

        s3.put_object(
          bucket: bucket,
          key: file_path,
          body: file_data,
          acl: 'private' # or 'public-read' depending on your requirements
        )

        true
      rescue Aws::S3::Errors::ServiceError => e
        Rails.logger.error("AWS S3 Error: #{e.message}")
        false
      end
    end

    def download(file_path)
      return nil if file_path.blank?

      begin
        s3 = aws_client
        bucket = aws_bucket

        response = s3.get_object(
          bucket: bucket,
          key: file_path
        )

        response.body.read
      rescue Aws::S3::Errors::ServiceError => e
        Rails.logger.error("AWS S3 Error: #{e.message}")
        nil
      end
    end

    def delete(file_path)
      return false if file_path.blank?

      begin
        s3 = aws_client
        bucket = aws_bucket

        s3.delete_object(
          bucket: bucket,
          key: file_path
        )

        true
      rescue Aws::S3::Errors::ServiceError => e
        Rails.logger.error("AWS S3 Error: #{e.message}")
        false
      end
    end

    def generate_presigned_url(file_path, expires_in: 3600)
      return nil if file_path.blank?

      begin
        s3 = aws_resource
        bucket = aws_bucket

        object = s3.bucket(bucket).object(file_path)
        object.presigned_url(:get, expires_in: expires_in)
      rescue Aws::S3::Errors::ServiceError => e
        Rails.logger.error("AWS S3 Error: #{e.message}")
        nil
      end
    end

    private

    def aws_client
      @aws_client ||= Aws::S3::Client.new(
        access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
        secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key),
        region: Rails.application.credentials.dig(:aws, :region) || 'us-east-1'
      )
    end

    def aws_resource
      @aws_resource ||= Aws::S3::Resource.new(
        access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
        secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key),
        region: Rails.application.credentials.dig(:aws, :region) || 'us-east-1'
      )
    end

    def aws_bucket
      Rails.application.credentials.dig(:aws, :bucket) || "recruit-mate-app-#{Rails.env}"
    end
  end
end
