# Performance tuning
workers <%= @num_cpus %>
threads 8,16
worker_timeout 60

# Detach master from bundler context
prune_bundler

# Configuration
rails_env = ENV['RAILS_ENV'] || 'production'
working_directory = File.expand_path('../../../../../current', './scripts/production/puma.rb')

# General config
environment rails_env
directory working_directory
pidfile "#{working_directory}/tmp/pids/puma.pid"
state_path "#{working_directory}/tmp/pids/puma.state"
stdout_redirect "#{working_directory}/log/puma.stdout.log", "#{working_directory}/log/puma.stderr.log"
bind "unix://#{working_directory}/tmp/sockets/puma.sock"

on_worker_boot do
  # ActiveSupport.on_load(:active_record) do
  #   ActiveRecord::Base.establish_connection
  # end
end
