require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      user = create(:user)
      company = described_class.new(name: 'Test Company', user: user)
      expect(company).to be_valid
    end

    it 'is not valid without a name' do
      user = create(:user)
      company = described_class.new(user: user)
      expect(company).not_to be_valid
    end

    it 'is not valid without a user' do
      company = described_class.new(name: 'Test Company')
      expect(company).not_to be_valid
    end
  end
end
