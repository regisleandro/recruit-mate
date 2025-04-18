FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    name { Faker::Name.name }
    jti { SecureRandom.uuid }

    trait :with_companies do
      after(:create) do |user|
        create_list(:company, 3, user: user)
      end
    end
  end
end
