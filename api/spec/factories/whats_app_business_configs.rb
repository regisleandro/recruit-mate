FactoryBot.define do
  factory :whats_app_business_config do
    access_token { 'MyString' }
    phone_number_id { 'MyString' }
    business_account_id { 'MyString' }
    verify_token { 'MyString' }
    recruiter { nil }
    user { nil }
  end
end
