require_relative '../rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'confirmation_instructions' do
    let(:user) { instance_double(User, email: 'to@example.org') }
    let(:token) { 'confirmation_token_123' }
    let(:mail) { described_class.confirmation_instructions(user, token) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Confirm your RecruitMate account')
      expect(mail.to).to eq(['to@example.org'])
      expect(mail.from).to eq(['no-reply@recruit-mate.example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Hi')
      expect(mail.body.encoded).to include(token)
    end
  end
end
