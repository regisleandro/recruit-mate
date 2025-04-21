class AddUserIdToRecruiters < ActiveRecord::Migration[7.1]
  def change
    add_reference :recruiters, :user, null: false, foreign_key: true
  end
end
