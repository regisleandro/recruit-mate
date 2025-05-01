class AddUserToRecruiters < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:recruiters, :user_id)
      add_reference :recruiters, :user, null: false, foreign_key: true
    end
  end
end
