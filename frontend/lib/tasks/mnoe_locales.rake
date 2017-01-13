#=============================================
# Enterprise Express Locales Tasks
#=============================================
# Enterprise Express tasks related to locales management
namespace :mnoe do
  namespace :locales do
    dist_locales_folder = 'public/dashboard/locales'
    tmp_locales_folder = 'tmp/build/frontend/src/locales'

    desc "Generate JSON locales"
    task :generate => :environment do
      MnoEnterprise::Frontend::LocalesGenerator.new(tmp_locales_folder).generate_json

      # Copy locales to public
      cp_r("#{tmp_locales_folder}/.", "#{dist_locales_folder}/")
    end
  end
end
