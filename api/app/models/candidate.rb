class Candidate < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :cpf, presence: true, uniqueness: true, format: { with: /\A\d{11}\z/, message: 'should be 11 digits' }
  validates :cellphone_number, format: { with: /\A\d{10,11}\z/, message: 'should be 10-11 digits' }, allow_blank: true

  # Update the curriculum path in the AWS S3 bucket
  def curriculum_path=(filename)
    return if filename.blank?

    # Format: user_id/candidate_id/file_name
    self.curriculum = "#{user_id}/#{id}/#{filename}"
  end

  # Get the full S3 URL for the curriculum file
  def curriculum_url
    return if curriculum.blank?

    # This will be configured with the actual AWS S3 bucket URL
    bucket_url = begin
      Rails.application.config.aws_bucket_url
    rescue StandardError
      nil
    end
    bucket_url ? "#{bucket_url}/#{curriculum}" : nil
  end
end
