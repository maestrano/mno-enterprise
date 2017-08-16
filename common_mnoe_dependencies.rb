# By placing all of Mnoe's shared dependencies in this file and then loading
# it for each component's Gemfile, we can be sure that we're only testing just
# the one component of Mnoe.
source 'https://rubygems.org'

gem 'sqlite3'

group :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'fakeweb', '~> 1.3'
  gem 'webmock', '~> 3.0.1'
  gem 'timecop'
  gem 'climate_control'
  # gem 'simplecov'
end

group :test, :development do
  gem 'figaro'
  # gem 'rubocop', require: false
end
