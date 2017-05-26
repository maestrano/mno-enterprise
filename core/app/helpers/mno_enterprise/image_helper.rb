module MnoEnterprise
  module ImageHelper
    # Helper method to easily access and select the images
    IMAGES_LOCATION = "/app/assets/images/mno_enterprise/"
    
    # If is_for_invoice is true returns logo appended to the path
    # If is_for_invoice is false returns logo detached to the path
    def main_logo_white_bg(is_for_invoice=false)
      logo = search_main_logo_white_bg
      is_for_invoice ? logo : "mno_enterprise/#{File.basename(logo)}"
    end

    # Return the main-logo-whitebg.png if exists, otherwise search main-logo.png
    def search_main_logo_white_bg
      app_image_path("main-logo-whitebg.png") || main_logo
    end

    # Return the main-logo.png if exists otherwise search for framework logo
    def main_logo
      logo = "main-logo.png"
      app_image_path(logo) || engine_image_path(logo)
    end

    # Build path and checks if the logo exists
    def app_image_path(logo)
      app_path = "#{Rails.root}#{IMAGES_LOCATION}#{logo}"
      app_path if File.exists?(app_path)
    end

    # Search for framework logo and return it
    def engine_image_path(logo)
      "#{MnoEnterprise::Engine.root}#{IMAGES_LOCATION}#{logo}"
    end
  end
end
