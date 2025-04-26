class CurriculumService
  def self.save_curriculum_file(candidate, file_data, original_filename)
    return false if file_data.blank? || original_filename.blank?

    # Sanitize the filename to prevent security issues
    sanitized_filename = sanitize_filename(original_filename)

    # If the candidate is a new record, we need to save it first to get an ID
    candidate.save! if candidate.new_record?

    # Set the curriculum path in the model with the proper ID
    candidate.curriculum_path = sanitized_filename

    # Update path if needed and upload file
    update_curriculum_path(candidate)
    upload_file_to_storage(candidate, file_data)
  end

  def self.delete_curriculum_file(candidate)
    return if candidate.curriculum.blank?

    AwsService.delete(candidate.curriculum)
  end

  class << self
    private

    def sanitize_filename(filename)
      filename.gsub(/[^0-9A-Za-z.\-]/, '_')
    end

    def update_curriculum_path(candidate)
      return unless candidate.curriculum&.include?('temp_')

      new_path = candidate.curriculum.gsub(/temp_\d+/, candidate.id.to_s)
      candidate.curriculum = new_path
    end

    def upload_file_to_storage(candidate, file_data)
      # Upload the file to AWS S3
      if AwsService.upload(file_data, candidate.curriculum)
        # Save the changes to the curriculum path
        candidate.save
        true
      else
        # If upload fails, clear the path
        candidate.curriculum = nil
        candidate.errors.add(:curriculum, 'Failed to upload file to storage')
        false
      end
    end
  end
end
