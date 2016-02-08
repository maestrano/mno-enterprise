# Used to create non-digested version of precompiled assets
#
# See:
# https://bibwild.wordpress.com/2014/10/02/non-digested-asset-names-in-rails-4-your-options/
# https://github.com/team-umlaut/umlaut/blob/master/lib/tasks/umlaut_asset_compile.rake

# Every time assets:precompile is called, trigger mnoe:create_non_digest_assets afterwards.
Rake::Task['assets:precompile'].enhance do
  Rake::Task['mnoe:create_non_digest_assets'].invoke
end

namespace :mnoe do
  # TODO: extract to a config of the App/Engine
  non_digest_named_assets = ['config.js']

  # This seems to be basically how ordinary asset precompile
  # is logging, ugh.
  logger = Logger.new($stderr)

  # Based on the rake task from umlaut.
  # Simplified since we use filename and not glob.
  task create_non_digest_assets: :"assets:environment" do
    # We cannot use Rails.application.assets_manifest as it's initalized before the precompile task runs
    manifest_path = Dir.glob(File.join(Rails.root, 'public/assets/.sprockets-manifest-*.json')).first
    manifest_data = JSON.load(File.new(manifest_path))

    assets = manifest_data['assets']

    # Original code:
    # if Umlaut::Engine.config.non_digest_named_assets.any? {|testpath| logical_pathname.fnmatch?(testpath, File::FNM_PATHNAME) }
    non_digest_named_assets.each do |logical_path|
      digested_path = assets[logical_path]

      full_digested_path    = File.join(Rails.root, 'public/assets', digested_path)
      full_nondigested_path = File.join(Rails.root, 'public/assets', logical_path)

      logger.info "(MNOE) Copying #{digested_path} to #{full_nondigested_path}"

      # Use FileUtils.copy_file with true third argument to copy
      # file attributes (eg mtime) too, as opposed to FileUtils.cp
      # Making symlnks with FileUtils.ln_s would be another option, not
      # sure if it would have unexpected issues.
      FileUtils.copy_file full_digested_path, full_nondigested_path, true
    end
  end
end
