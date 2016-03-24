#=============================================
# Rails task extension
#=============================================
# /*\ WARNING /*\
# Make sure you never screw with that tasks. Ever.
# Otherwise, deletion of all database data may occur.
#
# This task is used by the Ansible automation scripts
# to automatically setup/seed the database or migrate it
#
namespace :db do
  desc 'Migrate the database or set it up'
  task :migrate_or_setup => :environment do
    if ActiveRecord::Migrator.current_version > 0
      Rake::Task['db:migrate'].invoke
    else
      Rake::Task['db:setup'].invoke
    end
  end
end
