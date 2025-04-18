RSpec.configure do |config|
  config.before do
    # Mock CurriculumService.save_curriculum_file
    allow(CurriculumService).to receive(:save_curriculum_file)
      .and_wrap_original do |_original, candidate, file_data, original_filename|
        # Don't actually upload to AWS, but update the curriculum path
        if file_data.present? && original_filename.present?
          sanitized_filename = original_filename.gsub(/[^0-9A-Za-z.\-]/, '_')
          candidate.curriculum_path = sanitized_filename
          true
        else
          false
        end
      end

    # Mock CurriculumService.delete_curriculum_file
    allow(CurriculumService).to receive(:delete_curriculum_file).and_return(true)
  end
end
