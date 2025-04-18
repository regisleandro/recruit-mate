module CandidateHelpers
  # Helper method to set curriculum path and mimic the behavior of the old set_curriculum_path method
  def set_curriculum_path(candidate, filename)
    candidate.curriculum_path = filename
  end

  # Helper method to mimic the behavior of the old save_curriculum_file method
  delegate :save_curriculum_file, to: :CurriculumService
end

RSpec.configure do |config|
  config.include CandidateHelpers, type: :model
  config.include CandidateHelpers, type: :request
end
