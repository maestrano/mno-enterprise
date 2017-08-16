# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

# Library for stubbing and setting expectations on HTTP requests in Ruby.
require 'fakeweb'
require 'webmock/rspec'

require 'spec_helper'
require 'her'
require 'factory_girl_rails'
require 'shoulda/matchers'

# Load the Dummy application
require File.expand_path("../../spec/dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'

# Check Dummy application migrations
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../test/dummy/db/migrate", __FILE__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../../db/migrate', __FILE__)


# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("../..","spec/support/**/*.rb")].each { |f| require f }

# Require all factories
require 'mno_enterprise/testing_support/factories'
require 'mno_enterprise/testing_support/climate_control'

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  # Include FactoryGirl methods to avoid typing FactoryGirl.create(...)
  config.include FactoryGirl::Syntax::Methods

  # Include MnoEnterpriseApiTestHelper
  # Enable API stub helpers (e.g.: api_stub_for)
  config.include MnoEnterpriseApiTestHelper

  # Include ability test helper
  config.include AbilityTestHelper, type: :controller

  # Include devise tests
  config.include Devise::TestHelpers, type: :controller

  # Reset API stubs before each step
  config.before :each do
    api_stub_reset
  end

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
