class JobApplication < ApplicationRecord
  belongs_to :job
  belongs_to :candidate
  belongs_to :user

  validates :status, presence: true
  validates :candidate_id, uniqueness: { scope: :job_id, message: 'has already applied for this job' }

  # Define the status enum with all the required states for job applications
  enum status: {
    pending: 'pending',
    reviewing: 'reviewing',
    interviewing: 'interviewing',
    offered: 'offered',
    accepted: 'accepted',
    rejected: 'rejected',
    withdrawn: 'withdrawn'
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
