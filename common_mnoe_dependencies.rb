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
  gem 'fakeweb', '~> 1.3'
  gem 'timecop'
  # gem 'simplecov'
end

group :test, :development do
  # gem 'rubocop', require: false
end
