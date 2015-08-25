# desc "Explaining what the task does"
# task :mno_enterprise do
#   # Task goes here
# end

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
