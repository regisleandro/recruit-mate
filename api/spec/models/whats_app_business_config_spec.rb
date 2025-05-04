require 'rails_helper'

RSpec.describe WhatsAppBusinessConfig, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:recruiter) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:access_token) }
    it { is_expected.to validate_presence_of(:phone_number_id) }
    it { is_expected.to validate_presence_of(:business_account_id) }

    context 'when performing update' do
      subject { create(:whats_app_business_config, recruiter: recruiter, user: user) }

      let(:user) { create(:user) }
      let(:recruiter) { create(:recruiter, user: user) }

      it { is_expected.to validate_presence_of(:verify_token) }
    end
  end

  describe 'scopes' do
    describe '.by_user' do
      let(:owner_user) { create(:user) }
      let(:other_user) { create(:user) }
      let(:owner_recruiter) { create(:recruiter, user: owner_user) }
      let(:other_recruiter) { create(:recruiter, user: other_user) }

      before do
        create(:whats_app_business_config, recruiter: owner_recruiter, user: owner_user)
        create(:whats_app_business_config, recruiter: other_recruiter, user: other_user)
      end

      it 'returns configurations for the specified user' do
        expect(described_class.by_user(owner_user).count).to eq(1)
        expect(described_class.by_user(owner_user).first.user).to eq(owner_user)
      end
    end
  end

  describe 'callbacks' do
    describe '#ensure_verify_token' do
      let(:user) { create(:user) }
      let(:recruiter) { create(:recruiter, user: user) }

      it 'sets a verify token if none exists' do
        config = build(:whats_app_business_config, recruiter: recruiter, user: user, verify_token: nil)
        config.save
        expect(config.verify_token).not_to be_nil
      end

      it 'does not change existing verify token' do
        config = build(:whats_app_business_config, recruiter: recruiter, user: user, verify_token: 'existing_token')
        config.save
        expect(config.verify_token).to eq('existing_token')
      end
    end
  end

  describe '#to_s' do
    let(:user) { create(:user) }
    let(:recruiter) { create(:recruiter, user: user) }

    it 'returns a string with masked details' do
      config = create(:whats_app_business_config, recruiter: recruiter, user: user)
      expect(config.to_s).to match(/#<WhatsAppBusinessConfig id: \d+, recruiter_id: \d+>/)
    end
  end
end
