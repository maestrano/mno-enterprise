require 'fastimage'

module MnoEnterprise
  module ImageHelper

    IMAGES_LOCATION = "/app/assets/images/mno_enterprise/"

    # Helper method to easily access and select the images
    # If full_path is true returns filename appended to the path
    # If full_path is false returns filename
    # Return the main-logo-whitebg.png if exists, otherwise get main-logo.png
    def main_logo_white_bg_path(full_path=false)
      logo_path = app_image_path("main-logo-whitebg.png") || main_logo_path
      full_path ? logo_path : "mno_enterprise/#{File.basename(logo_path)}"
    end

    # Return the main-logo.png if exists otherwise get engine's logo
    def main_logo_path
      file_name = "main-logo.png"
      app_image_path(file_name) || engine_image_path(file_name)
    end

    # Build path and checks if the logo exists
    def app_image_path(file_name)
      app_path = "#{Rails.root}#{IMAGES_LOCATION}#{file_name}"
      app_path if File.exists?(app_path)
    end

    # Get engine's logo and return it
    def engine_image_path(file_name)
      "#{MnoEnterprise::Engine.root}#{IMAGES_LOCATION}#{file_name}"
    end

    def fit_image
      'max-width: 150px; max-height: 150px;'
    end

    def main_logo_white_bg_dimensions
      FastImage.size(main_logo_white_bg_path(true))
    end

    # Returns dimensions for the main_logo_white_bg, with width < 150px && height < 150px
    # while keeping the same aspect ratio
    def main_logo_white_bg_size_to_fit
      dimensions = main_logo_white_bg_dimensions
      original_width, original_height = dimensions
      return { width: original_width, height: original_height } if original_width < 150 && original_height < 150

      if original_width > original_height
        width = [original_width, 150].min
        height = width * original_height / original_width
      else
        height = [original_height, 150].min
        width = height * original_width / original_height
      end
      { width: width, height: height }
    end
  end
end
