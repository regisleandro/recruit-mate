class Recruiter < ApplicationRecord
  belongs_to :user
  has_one :whats_app_business_config, dependent: :destroy
end
