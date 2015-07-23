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
      Rails.root
    end
    
    # Return the engine root path
    def self.engine_root_path
      MnoEnterprise::Engine.root
    end
    
    def self.images
      [self.root_path, self.engine_root_path].map do |base_path|
        Dir.glob(base_path.join("app/assets/images/**/*.*")).map do |path| 
          path.gsub(base_path.join("app/assets/images/").to_s, "")
        end
      end.flatten.uniq
    end
  
    def self.templates
      [self.root_path, self.engine_root_path].map do |base_path|
        Dir.glob(base_path.join("app/assets/templates/**/*.*")).map do |path| 
          path.gsub(base_path.join("app/assets/templates/").to_s, "")
        end
      end.flatten.uniq
    end
  end
end