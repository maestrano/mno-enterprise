#=============================================
# Enterprise Express Locales Tasks
#=============================================
# Enterprise Express tasks related to locales management
namespace :mnoe do
  namespace :locales do
    locales_folder = 'public/dashboard/locales'

    desc "Generate JSON locales"
    task :generate => :environment do
      MnoEnterprise::Frontend::LocalesGenerator.new(locales_folder).generate_json
    end
  end
end
