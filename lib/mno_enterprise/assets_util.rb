# Used by assets.js.erb to reference
# images from Asset pipeline
module MnoEnterprise
  module AssetsUtil
    def self.assets_url
      self.config["environments"][Rails.env]["assets"]
    end
  
    def self.server_host
      self.config["environments"][Rails.env]["host"]
    end

    def self.config
      @@config ||= YAML.load_file(File.join(Rails.root, 'config', 'assets.yml'))

      @@config
    end
    
    # Return the application root path
    def self.root_path
      MnoEnterprise::Engine.root
    end
    
    def self.images
      Dir.glob(self.root_path.join("app/assets/images/**/*.*")).map do |path| 
        path.gsub(MnoEnterprise::Engine.root.join("app/assets/images/").to_s, "")
      end
    end
  
    def self.templates
      Dir.glob(self.root_path.join("app/assets/templates/**/*.*")).map do |path| 
        path.gsub(self.root_path.join("app/assets/templates/").to_s, "")
      end
    end
  end
end