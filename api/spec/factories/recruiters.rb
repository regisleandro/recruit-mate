FactoryBot.define do
  factory :recruiter do
    name { "#{Faker::Company.name} Recruiter" }
    prompt { Faker::Lorem.paragraph(sentence_count: 3) }
    telegram_token { SecureRandom.hex(10) }
    association :user
  end
end
