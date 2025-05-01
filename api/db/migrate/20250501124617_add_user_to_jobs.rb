class AddUserToJobs < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:jobs, :user_id)
      add_reference :jobs, :user, null: false, foreign_key: true
    end
  end
end
