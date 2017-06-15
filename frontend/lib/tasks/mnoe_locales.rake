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

      Rake::Task['mnoe:locales:append_impac'].invoke

      # Copy locales to public
      cp_r("#{locales_tmp_folder}/.","#{locales_dist_folder}/")
    end

    task :append_impac do
      # Copy impac locales to public/dashboard/locales/impac
      locales_impac_folder = 'tmp/build/frontend/bower_components/impac-angular/dist/locales/'
      cp_r("#{locales_impac_folder}/.","#{locales_dist_folder}/impac/")

      # TODO: remove when locales moved to four letters
      # 4-letters locales --> 2-letters locales
      dir = "#{locales_dist_folder}/impac/"
      Dir.foreach(dir) do |f|
        next unless f.include?(".json")
        File.rename("#{dir}#{f}", "#{dir}#{f.slice(0,2)}.json")
      end
    end
  end
end
