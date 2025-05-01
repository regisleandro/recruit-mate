class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # General scope to filter records by user
  # Usage: Model.by_user(current_user)
  scope :by_user, ->(user) { where(user_id: user.id) if user.present? }
end
