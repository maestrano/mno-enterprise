module MnoEnterprise
  module ImageHelper
    
    IMAGES_LOCATION = "/app/assets/images/mno_enterprise/"
    
    # Helper method to easily access and select the images
    # If full_path is true returns filename appended to the path
    # If full_path is false returns filename
    def main_logo_white_bg_path(full_path=false)
      # Return the main-logo-whitebg.png if exists, otherwise get main-logo.png
      logo_path = app_image_path("main-logo-whitebg.png") || main_logo_path
      full_path ? logo_path : "mno_enterprise/#{File.basename(logo_path)}"
    end

    # Return the main-logo.png if exists otherwise get for framework logo
    def main_logo_path
      file_name = "main-logo.png"
      app_image_path(file_name) || engine_image_path(file_name)
    end

    # Build path and checks if the logo exists
    def app_image_path(file_name)
      app_path = "#{Rails.root}#{IMAGES_LOCATION}#{file_name}"
      app_path if File.exists?(app_path)
    end

    # Get framework logo and return it
    def engine_image_path(file_name)
      "#{MnoEnterprise::Engine.root}#{IMAGES_LOCATION}#{file_name}"
    end
  end
end
