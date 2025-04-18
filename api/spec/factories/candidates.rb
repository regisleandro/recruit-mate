FactoryBot.define do
  factory :candidate do
    name { Faker::Name.name }
    curriculum { nil }
    curriculum_summary { Faker::Lorem.paragraph(sentence_count: 3) }
    cellphone_number { rand((10**10)..(10**11) - 1).to_s } # Generate 10-11 random digits
    cpf { Array.new(11) { rand(10) }.join } # Generate 11 random digits
    association :user
  end
end
