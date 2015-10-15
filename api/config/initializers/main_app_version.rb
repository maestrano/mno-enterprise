# Set the application version from the VERSION file in the root folder
version_file = "#{Rails.root}/BUILD_NUMBER"
git_version = `git rev-parse --short HEAD`.chomp rescue nil
build_number = File.new(version_file).read if File.exists?(version_file)

MnoEnterprise::APP_VERSION = [build_number, git_version].compact.join('-')
