class AddUserToCompanies < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:companies, :user_id)
      add_reference :companies, :user, null: false, foreign_key: true
    end
  end
end
