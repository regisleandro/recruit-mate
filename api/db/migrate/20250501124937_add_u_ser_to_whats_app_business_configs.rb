class AddUSerToWhatsAppBusinessConfigs < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:whats_app_business_configs, :user_id)
      add_reference :whats_app_business_configs, :user, null: false, foreign_key: true
    end
  end
end
