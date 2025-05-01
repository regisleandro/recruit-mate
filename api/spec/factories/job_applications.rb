FactoryBot.define do
  factory :job_application do
    candidate
    job
    user
    status { :pending }
    notes { 'Application notes text' }
  end
end
