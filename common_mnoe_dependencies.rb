# By placing all of Mnoe's shared dependencies in this file and then loading
# it for each component's Gemfile, we can be sure that we're only testing just
# the one component of Mnoe.
source 'https://rubygems.org'

# sqlite3_adapter requires 1.3.x
gem 'sqlite3', '~> 1.3.13'

group :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'webmock', '~> 3.4.2'
  gem 'timecop'
  gem 'climate_control'
  # gem 'simplecov'
  gem 'fakefs', require: 'fakefs/safe'
end

group :test, :development do
  gem 'figaro'
  # gem 'rubocop', require: false
end
