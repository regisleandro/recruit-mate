class AddUserToJobApplications < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:job_applications, :user_id)
      add_reference :job_applications, :user, null: false, foreign_key: true
    end
  end
end
