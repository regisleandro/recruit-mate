class Job < ApplicationRecord
  belongs_to :company
  has_many :job_applications, dependent: :destroy
  has_many :candidates, through: :job_applications

  validates :description, presence: true
  validates :status, presence: true
  validates :title, presence: true

  # Define the status enum with all the required states
  enum :status, {
    draft: 0,
    open: 1,
    on_hold: 2,
    in_review: 3,
    interviewing: 4,
    offer_extended: 5,
    offer_accepted: 6,
    closed: 7,
    archived: 8,
    offer_declined: 9,
    reopened: 10,
    cancelled: 11
  }

  # Scopes for easier querying
  scope :active, -> { where(status: %i[draft open on_hold in_review interviewing offer_extended]) }
  scope :completed, -> { where(status: %i[offer_accepted closed archived offer_declined cancelled]) }

  # Custom validation for time fields
  validate :end_time_after_start_time, if: -> { start_time.present? && end_time.present? }
  validate :validate_interval_time, if: -> { interval_time.present? }

  def active?
    %w[draft open on_hold in_review interviewing offer_extended].include?(status)
  end

  private

  def end_time_after_start_time
    return unless end_time <= start_time

    errors.add(:end_time, 'must be after start time')
  end

  def validate_interval_time
    return unless interval_time <= 0

    errors.add(:interval_time, 'must be greater than 0')
  end
end
