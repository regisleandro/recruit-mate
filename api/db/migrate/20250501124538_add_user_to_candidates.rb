class AddUserToCandidates < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:candidates, :user_id)
      add_reference :candidates, :user, null: false, foreign_key: true
    end
  end
end
