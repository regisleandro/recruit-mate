# This configuration sets up ActiveRecord::Encryption for securely
# storing sensitive WhatsApp Business API credentials.

# Note: In a production environment, use actual environment variables 
# instead of hardcoded values.

Rails.application.config.to_prepare do
  ActiveRecord::Encryption.configure(
    # Primary key for encryption - in production, use ENV['ENCRYPTION_PRIMARY_KEY']
    primary_key: ENV.fetch('ENCRYPTION_PRIMARY_KEY', 'dfc77973291d9c2ca4e6e0426e583bc6'),
    
    # Deterministic key for searchable encryption - in production, use ENV['ENCRYPTION_DETERMINISTIC_KEY']
    deterministic_key: ENV.fetch('ENCRYPTION_DETERMINISTIC_KEY', '3a66361f96ef3063ff4785df12646796'),
    
    # Key derivation salt - in production, use ENV['ENCRYPTION_KEY_DERIVATION_SALT']
    key_derivation_salt: ENV.fetch('ENCRYPTION_KEY_DERIVATION_SALT', '3ae0485c826fb9a95c8d8435a939efdd'),
    
    # These settings are important to avoid interference with Devise
    support_unencrypted_data: true,  # Allow reading unencrypted data (helps with existing data)
    encrypt_fixtures: false,         # Don't encrypt test fixtures
    validate_encryption_key_uniqueness: false # Skip validation that might interfere with Devise setup
  )
end 