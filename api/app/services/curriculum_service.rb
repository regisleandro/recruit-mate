class CurriculumService
  def self.save_curriculum_file(candidate, file_data, original_filename)
    return false if file_data.blank? || original_filename.blank?

    # Sanitize the filename to prevent security issues
    sanitized_filename = original_filename.gsub(/[^0-9A-Za-z.\-]/, '_')

    # Set the curriculum path in the model
    candidate.curriculum_path = sanitized_filename

    # Upload the file to AWS S3
    if AwsService.upload(file_data, candidate.curriculum)
      true
    else
      # If upload fails, clear the path
      candidate.curriculum = nil
      candidate.errors.add(:curriculum, 'Failed to upload file to storage')
      false
    end
  end

  def self.delete_curriculum_file(candidate)
    return if candidate.curriculum.blank?

    AwsService.delete(candidate.curriculum)
  end
end
