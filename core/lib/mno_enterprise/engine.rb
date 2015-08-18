module MnoEnterprise
  class Engine < ::Rails::Engine
    isolate_namespace MnoEnterprise
    
    # Autoload all files and sub-directories in
    # lib
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end
    
    # Allow class overriding using decorator pattern
    # See: http://edgeguides.rubyonrails.org/engines.html#overriding-models-and-controllers
    config.to_prepare do
      Dir.glob(Rails.root + "app/decorators/**/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
    end

    # Add responding to JSON to Devise
    config.to_prepare do
      DeviseController.respond_to :html, :json
    end
  end
end
