require 'rake'

Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
Rails.application.load_tasks # load application tasks

module MnoEnterprise
  class Jpi::V1::Admin::ThemeController < Jpi::V1::Admin::BaseResourceController
    # No xsrf
    skip_before_filter :verify_authenticity_token

    # POST /mnoe/jpi/v1/admin/theme/save
    def save
      if params[:publish]
        # Recompile style for production use
        apply_previewer_style(params[:theme])
        publish_style
      else
        # Save and rebuild previewer style only
        # (so it is kept across page reloads)
        save_previewer_style(params[:theme])
        rebuild_previewer_style
      end

      render json: {status:  'Ok'},  status: :created
    end

    # POST /mnoe/jpi/v1/admin/theme/reset
    def reset
      reset_previewer_style
      rebuild_previewer_style
      render json: {status:  'Ok'}
    end

    # POST /mnoe/jpi/v1/admin/theme/logo
    def logo
      logo_content = params[:logo].read
      [
        'frontend/src/images/main-logo.png',
        'public/dashboard/images/main-logo.png',
        'app/assets/images/mno_enterprise/main-logo.png'
      ].each do |filepath|
        FileUtils.mkdir_p(File.dirname(Rails.root.join(filepath)))
        File.open(Rails.root.join(filepath),'wb') { |f| f.write(logo_content) }
      end
      render json: {status:  'Ok'},  status: :created
    end

    #=====================================================
    # Protected
    #=====================================================
    protected

      # Save current style to theme-previewer-tmp.less stylesheet
      # This file overrides theme-previewer-published.less
      def save_previewer_style(theme)
        target = Rails.root.join('frontend', 'src','app','stylesheets','theme-previewer-tmp.less')
        File.open(target, 'w') { |f| f.write(params[:theme]) }
      end

      # Save style to theme-previewer-published.less and discard theme-previewer-tmp.less
      def apply_previewer_style(theme)
        target = Rails.root.join('frontend', 'src','app','stylesheets','theme-previewer-published.less')
        File.open(target, 'w') { |f| f.write(params[:theme]) }
        reset_previewer_style
      end

      def reset_previewer_style
        target = Rails.root.join('frontend', 'src','app','stylesheets','theme-previewer-tmp.less')
        File.exist?(target) && File.delete(target)
      end

      def rebuild_previewer_style
        Rake::Task['mnoe:frontend:rebuild_previewer_style'].reenable
        Rake::Task['mnoe:frontend:rebuild_previewer_style'].invoke
      end

      def publish_style
        Rake::Task['mnoe:frontend:dist'].reenable
        Rake::Task['mnoe:frontend:dist'].invoke
      end
  end
end
