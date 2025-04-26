require 'rails_helper'

RSpec.describe Job, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:company) }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      job = build(:job)
      expect(job).to be_valid
    end

    it 'is not valid without a description' do
      job = build(:job, description: nil)
      expect(job).not_to be_valid
    end

    it 'is not valid without a title' do
      job = build(:job, title: nil)
      expect(job).not_to be_valid
    end

    it 'is not valid if end_time is before start_time' do
      job = build(:job, start_time: Time.current, end_time: 1.day.ago)
      expect(job).not_to be_valid
      expect(job.errors[:end_time]).to include('must be after start time')
    end

    it 'is not valid with a negative interval_time' do
      job = build(:job, interval_time: -5)
      expect(job).not_to be_valid
      expect(job.errors[:interval_time]).to include('must be greater than 0')
    end
  end

  describe 'enums' do
    it 'defines the correct status enum values' do
      expected_statuses = %i[
        draft open on_hold in_review interviewing offer_extended
        offer_accepted closed archived offer_declined reopened cancelled
      ]

      expect(described_class.statuses.keys.map(&:to_sym)).to match_array(expected_statuses)
    end
  end

  describe 'scopes' do
    before do
      create(:job, :draft)
      create(:job, :open)
      create(:job, :closed)
    end

    it 'returns active jobs' do
      expect(described_class.active.count).to eq(2)
    end

    it 'returns completed jobs' do
      expect(described_class.completed.count).to eq(1)
    end
  end

  describe '#active?' do
    it 'returns true for active statuses' do
      job = build(:job, status: :open)
      expect(job).to be_active
    end

    it 'returns false for completed statuses' do
      job = build(:job, status: :closed)
      expect(job).not_to be_active
    end
  end
end
