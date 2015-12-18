require 'less-rb'
module MnoEnterprise
  class Jpi::V1::Admin::ThemeController < Jpi::V1::Admin::BaseResourceController
    # No xsrf
    skip_before_filter :verify_authenticity_token

    def save
      save_theme_less
      recompile_css

      render json: {status:  'Ok'},  status: :created
    end

    def logo
      uploaded_io = params[:logo]
      File.open(Rails.root.join('public/assets/images', 'main-logo.png'), 'wb') do |f|
        f.write(uploaded_io.read)
      end
      render json: {status:  'Ok'},  status: :created
    end

    protected

    def save_theme_less
      target = Rails.root.join('public', 'styles', 'theme.less')
      File.open(target, 'w') { |f| f.write(params[:theme]) }
    end

    def recompile_css
      # Concatenate the 2 less files
      less = File.read(Rails.root.join('public', 'styles', 'app.less'))
      less += File.read(Rails.root.join('public', 'styles', 'theme.less'))

      # Compile to CSS
      parser = Less::Parser.new paths: [Rails.root.join('public', 'styles').to_s], filename: 'app.less'
      tree = parser.parse(less)
      css = tree.to_css(compress: true)

      # Write to the css file
      write_css(css['css'])
    end

    # Extract the current app-*.css filepath by parsing index.html
    def extract_app_css_path
      filename = File.read(Rails.root.join('public/index.html')).scan(/(styles\/app-.*.css)/).flatten.first
      Rails.root.join('public', filename)
    end

    def write_css(data)
      File.open(extract_app_css_path, 'w') { |f| f.write(data) }
    end
  end
end
