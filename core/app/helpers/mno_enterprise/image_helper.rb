module MnoEnterprise
  module ImageHelper
    # Helper method to easily access and select the images
    def select_image
      path = "/app/assets/images/"

      main_logo_whitebg = "#{path}mno_enterprise/main-logo-whitebg.png"
      return image(main_logo_whitebg) if image(main_logo_whitebg)

      main_logo = "#{path}mno_enterprise/main-logo.png"
      return image(main_logo) if image(main_logo)

      return "#{MnoEnterprise::Engine.root}#{main_logo}"
    end

    def image(logo)
      app_path = "#{Rails.root}#{logo}"
      return app_path if File.exists?(app_path)
    end

  end
end
