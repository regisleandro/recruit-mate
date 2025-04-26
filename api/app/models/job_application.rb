class JobApplication < ApplicationRecord
  belongs_to :candidate
  belongs_to :job

  validates :status, presence: true
  validates :candidate_id, uniqueness: { scope: :job_id, message: 'has already applied for this job' }

  # Define the status enum with all the required states for job applications
  enum :status, {
    pending: 0,
    reviewing: 1,
    phone_screen: 2,
    interviewing: 3,
    technical_test: 4,
    reference_check: 5,
    offered: 6,
    accepted: 7,
    rejected: 8,
    withdrawn: 9
  }

  # Scopes for easier querying
  scope :active, lambda {
    where(status: %i[pending reviewing phone_screen interviewing technical_test reference_check offered])
  }
  scope :completed, -> { where(status: %i[accepted rejected withdrawn]) }

  def active?
    %w[pending reviewing phone_screen interviewing technical_test reference_check offered].include?(status)
  end
end
