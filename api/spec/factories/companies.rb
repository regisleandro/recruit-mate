FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    association :user
  end
end
