class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :companies, dependent: :destroy
  has_many :recruiters, dependent: :destroy
  has_many :candidates, dependent: :destroy
  has_many :jobs, dependent: :destroy
  has_many :job_applications, dependent: :destroy
  has_many :whats_app_business_configs, through: :recruiters
end
