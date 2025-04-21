class AddVerifyTokenToWhatsAppBusinessConfigs < ActiveRecord::Migration[7.1]
  def change
    add_column :whats_app_business_configs, :verify_token, :string
  end
end
