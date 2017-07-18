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

      Rake::Task['mnoe:locales:impac'].invoke
    end

    desc "Copy impac locales to the public locales folder"
    task :impac do
      locales_impac_folder = 'tmp/build/frontend/bower_components/impac-angular/dist/locales'

      # impac-angular < 1.5.0-rc8 doesn't contain locales
      if Dir.exists?(locales_impac_folder)
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
end
