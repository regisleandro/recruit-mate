require 'rails_helper'

RSpec.describe Candidate, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    subject { create(:candidate, user: user) }

    let(:user) { create(:user) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:cpf) }
    it { is_expected.to validate_uniqueness_of(:cpf).case_insensitive }

    it { is_expected.to allow_value('12345678901').for(:cpf) }
    it { is_expected.not_to allow_value('1234567890').for(:cpf) } # Too short
    it { is_expected.not_to allow_value('123456789012').for(:cpf) } # Too long
    it { is_expected.not_to allow_value('1234567890a').for(:cpf) } # Not all digits

    it { is_expected.to allow_value('1234567890').for(:cellphone_number) }
    it { is_expected.to allow_value('12345678901').for(:cellphone_number) }
    it { is_expected.not_to allow_value('123456789').for(:cellphone_number) } # Too short
    it { is_expected.not_to allow_value('123456789012').for(:cellphone_number) } # Too long
    it { is_expected.not_to allow_value('1234567890a').for(:cellphone_number) } # Not all digits
  end

  describe 'methods' do
    let(:user) { create(:user) }
    let(:candidate) { create(:candidate, user: user) }

    describe '#curriculum_path=' do
      it 'sets the curriculum path with the proper format' do
        set_curriculum_path(candidate, 'test.pdf')
        expect(candidate.curriculum).to eq("#{user.id}/#{candidate.id}/test.pdf")
      end

      it 'does not change the curriculum if filename is blank' do
        original_curriculum = candidate.curriculum
        set_curriculum_path(candidate, '')
        expect(candidate.curriculum).to eq(original_curriculum)
      end
    end

    describe '#curriculum_url' do
      before do
        allow(Rails.application.config).to receive(:aws_bucket_url).and_return('https://bucket.s3.amazonaws.com')
        candidate.curriculum = "#{user.id}/#{candidate.id}/test.pdf"
      end

      it 'returns the full S3 URL when curriculum is present' do
        expect(candidate.curriculum_url).to eq("https://bucket.s3.amazonaws.com/#{user.id}/#{candidate.id}/test.pdf")
      end

      it 'returns nil when curriculum is not present' do
        candidate.curriculum = nil
        expect(candidate.curriculum_url).to be_nil
      end
    end

    describe 'save_curriculum_file' do
      it 'delegates to CurriculumService with the right parameters' do
        # Setup spy
        allow(CurriculumService).to receive(:save_curriculum_file).and_return(true)

        # Call the method
        save_curriculum_file(candidate, 'test_data', 'test.pdf')

        # Verify it was called with correct parameters
        expect(CurriculumService).to have_received(:save_curriculum_file)
          .with(candidate, 'test_data', 'test.pdf')
      end
    end
  end
end
