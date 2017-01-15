#=============================================
# Enterprise Express Locales Tasks
#=============================================
# Enterprise Express tasks related to locales management
namespace :mnoe do
  namespace :locales do
    locales_dist_folder = 'public/dashboard/locales'
    locales_tmp_folder = 'tmp/build/frontend/src/locales'

    desc "Generate JSON locales"
    task :generate => :environment do
      MnoEnterprise::Frontend::LocalesGenerator.new(locales_tmp_folder).generate_json

      # Copy locales to public
      cp_r("#{locales_tmp_folder}/.","#{locales_dist_folder}/")
    end
  end
end
