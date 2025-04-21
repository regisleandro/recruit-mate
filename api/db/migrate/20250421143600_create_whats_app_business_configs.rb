class CreateWhatsAppBusinessConfigs < ActiveRecord::Migration[7.1]
  def change
    create_table :whats_app_business_configs do |t|
      t.string :access_token
      t.string :phone_number_id
      t.string :business_account_id
      t.string :webhook_secret
      t.references :recruiter, null: false, foreign_key: true

      t.timestamps
    end
  end
end
