require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

# Load support files
Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_path = Rails.root.join('spec', 'fixtures', 'fixtures').to_s
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # Include Factory Bot methods
  config.include FactoryBot::Syntax::Methods

  # Database Cleaner configuration
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  # Include our devise jwt test helpers
  config.include DeviseJwtTestHelpers, type: :request
end
