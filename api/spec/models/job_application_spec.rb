require 'rails_helper'

RSpec.describe JobApplication, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:candidate) }
    it { is_expected.to belong_to(:job) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }

    it 'validates uniqueness of candidate_id scoped to job_id' do
      candidate = create(:candidate)
      job = create(:job)
      create(:job_application, candidate: candidate, job: job)

      duplicate_application = build(:job_application, candidate: candidate, job: job)
      expect(duplicate_application).not_to be_valid
      expect(duplicate_application.errors[:candidate_id]).to include('has already applied for this job')
    end
  end

  describe 'enums' do
    subject(:job_application) { build(:job_application) }

    it {
      expect(job_application).to define_enum_for(:status).with_values(
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
      )
    }
  end

  describe 'scopes' do
    let(:first_candidate) { create(:candidate) }
    let(:second_candidate) { create(:candidate) }
    let(:third_candidate) { create(:candidate) }
    let(:first_job) { create(:job) }
    let(:second_job) { create(:job) }

    let!(:pending_application) { create_application(:pending, first_candidate, first_job) }
    let!(:interviewing_application) { create_application(:interviewing, second_candidate, second_job) }
    let!(:rejected_application) { create_application(:rejected, third_candidate, create(:job)) }

    it 'active scope returns active applications' do
      expect(described_class.active).to include(pending_application, interviewing_application)
      expect(described_class.active).not_to include(rejected_application)
    end

    it 'completed scope returns completed applications' do
      expect(described_class.completed).to include(rejected_application)
      expect(described_class.completed).not_to include(pending_application, interviewing_application)
    end

    def create_application(status, candidate, job)
      create(:job_application, candidate: candidate, job: job, status: status)
    end
  end

  describe '#active?' do
    it 'returns true for active statuses' do
      application = build(:job_application, status: :pending)
      expect(application.active?).to be true

      application = build(:job_application, status: :interviewing)
      expect(application.active?).to be true
    end

    it 'returns false for completed statuses' do
      application = build(:job_application, status: :rejected)
      expect(application.active?).to be false

      application = build(:job_application, status: :accepted)
      expect(application.active?).to be false
    end
  end
end
