FactoryBot.define do
  factory :job do
    title { Faker::Job.title }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    benefits { Faker::Lorem.paragraph(sentence_count: 2) }
    keywords { "#{Faker::Job.field},#{Faker::Job.key_skill},#{Faker::Job.key_skill}" }
    start_time { Time.current }
    end_time { 30.days.from_now }
    interval_time { [15, 30, 45, 60].sample } # minutes
    status { Job.statuses.keys.sample }
    prompt { Faker::Lorem.paragraph(sentence_count: 4) }
    association :company

    trait :draft do
      status { :draft }
    end

    trait :open do
      status { :open }
    end

    trait :closed do
      status { :closed }
    end
  end
end
