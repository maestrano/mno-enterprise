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
  end
end
