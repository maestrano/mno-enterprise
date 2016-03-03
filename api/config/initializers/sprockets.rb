class Sprockets::DirectiveProcessor
  def process_depend_on_config_directive
    ['settings.yml', "settings/#{Rails.env}.yml"].each do |file|
      begin
        resolve(file)
      rescue Sprockets::FileNotFound
        Rails.logger.error "Could not find #{file}"
      end
    end
  end
end
