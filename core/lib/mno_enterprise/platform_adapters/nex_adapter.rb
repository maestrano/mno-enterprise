# frozen_string_literal: true
gem 'nex_client', '~> 0.17.0'
require 'nex_client'
require 'rake'

Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
Rails.application.load_tasks # load application tasks

module MnoEnterprise
  module PlatformAdapters
    # Nex!™ Adapter for MnoEnterprise::PlatformClient for apps with only one node
    # The Nex!™ docker image provide `awscli` and a Minio storage addon
    class NexAdapter < Adapter
      class << self
        ASSETS = [
          {
            local: :public_folder,
            remote: 's3://${MINIO_BUCKET}/public/',
            files: [
              'dashboard/styles/theme-previewer.less',
              'dashboard/styles/app-*.css',
              '*/main-logo.png'
            ]
          },
          {
            local: :frontend_folder,
            remote: 's3://${MINIO_BUCKET}/frontend/',
            files: [
              'app/stylesheets/theme-previewer-*.less',
              'images/main-logo.png'
            ]
          }
        ]

        # @see MnoEnterprise::PlatformAdapters::Adapter#restart
        def restart(timestamp = nil)
          FileUtils.touch('tmp/restart.txt')
          Rails.cache.write('config_timestamp', timestamp)
        end

        def restart_status
          timestamp = Rails.cache.fetch('config_timestamp')
          if Rails.cache.is_a?(ActiveSupport::Cache::MemoryStore)
            # If the app has properly restarted, MemoryStore will be cleared
            return 'success' unless timestamp
            return 'pending' unless Settings.config_timestamp && timestamp <= Settings.config_timestamp
            'failed'
          else
            return 'failed' unless timestamp && timestamp >= Settings.config_timestamp
            return 'pending' unless Settings.config_timestamp && timestamp <= Settings.config_timestamp
            'success'
          end
        end

        # @see MnoEnterprise::PlatformAdapters::Adapter#clear_assets
        def clear_assets
          # Clear the whole bucket
          %x(#{aws_cli} s3 rm s3://${MINIO_BUCKET} --recursive)
          $?.exitstatus == 0
        end

        # @see MnoEnterprise::PlatformAdapters::Adapter#publish_assets
        def publish_assets
          ASSETS.each do |conf|
            opts = generate_opts(conf[:files])
            sync_assets(send(conf[:local]), conf[:remote], opts)
          end

          copy_asset(logo_file, 's3://${MINIO_BUCKET}/assets/main-logo.png')
        end

        # @see MnoEnterprise::PlatformAdapters::Adapter#fetch_assets
        # Using `--exact-timestamps` to sync assets from S3 when they have the same size
        def fetch_assets
          sync_assets('s3://${MINIO_BUCKET}/public/', public_folder, "--exact-timestamps --exclude 'public/dashboard/index.html'")
          sync_assets('s3://${MINIO_BUCKET}/frontend/', frontend_folder, '--exact-timestamps')
          copy_asset('s3://${MINIO_BUCKET}/assets/main-logo.png', logo_file)

          # We don't want to override dashboard/index.html in case of upgrade, we just need to rebuild the new style
          # with our custom variables
          Rake::Task['mnoe:frontend:previewer:build'].reenable
          Rake::Task['mnoe:frontend:previewer:build'].invoke
        end

        # @see MnoEnterprise::PlatformAdapters::Adapter#update_domain
        def update_domain(domain_name)
          domain = NexClient::Domain.new(cname: domain_name)
          domain.relationships.origin = nex_app
          domain.save

          # Display errors if any
          if domain.errors.any?
            # display_record_errors(domain)
            false
          else
            domain
          end
        end

        # @see MnoEnterprise::PlatformAdapters::Adapter#add_ssl_certs
        def add_ssl_certs(cert_name, public_cert, cert_bundle, private_key)
          cert = NexClient::SslCertificate.new(
            cname: cert_name,
            public_cert: public_cert,
            cert_bundle: cert_bundle,
            private_key: private_key
          )
          cert.relationships.origin = nex_app
          cert.save

          # Display errors if any
          if cert.errors.any?
            # display_record_errors(cert)
            false
          else
            cert
          end
        end

        protected

        # Configure the Nex!™ client
        def setup_nex_client
          # Set endpoint
          NexClient::BaseResource.site = "#{ENV['SELF_NEX_API_ENDPOINT']}/api/v1"

          # Set authentication
          NexClient::BaseResource.connection(true) do |connection|
            connection.use Faraday::Request::BasicAuthentication, ENV['SELF_NEX_API_KEY'], ''
          end
        end

        def nex_app
          @nex_app ||= begin
            setup_nex_client
            NexClient::App.find(ENV['SELF_NEX_APP_ID']).first
          end
        end

        def public_folder
          @public_folder ||= Rails.root.join('public')
        end

        def frontend_folder
          @frontend_folder ||= Rails.root.join('frontend', 'src')
        end

        def logo_file
          @logo_file ||= Rails.root.join('app', 'assets', 'images', 'mno_enterprise', 'main-logo.png')
        end

        def aws_auth
          @aws_auth ||= 'AWS_ACCESS_KEY_ID=${MINIO_ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${MINIO_SECRET_KEY}'
        end

        def aws_cli
          @aws_cli ||= "#{aws_auth} aws --endpoint-url ${MINIO_URL}"
        end

        # Generate cli sync options to only include the specified list of files
        # Note: exclude *needs* to be before the include
        # @param [Array<String>] files the list of files to include
        # @return [String] the cli option String
        def generate_opts(files)
          files.map{|f| "--include '#{f}'"}.unshift("--exclude '*' --delete").join(' ')
        end

        # Syncs directories and S3 prefixes.
        # Recursively copies new and updated files from the source directory to the destination.
        #
        # @param [Object] src
        # @param [Object] dst
        # @param [String] options options to pass to the aws cli
        # @return [boolean] `true` if the operation was successful
        def sync_assets(src, dst, options=nil)
          if ENV['MINIO_URL'] && ENV['MINIO_BUCKET']
            args = [src, dst, options].compact.join(' ')
            %x(#{"#{aws_cli} s3 sync #{args}"})
            $?.exitstatus == 0
          end
        end

        # Copies a local file or S3 object to another location locally or in S3.
        def copy_asset(src, dst, options=nil)
          if ENV['MINIO_URL'] && ENV['MINIO_BUCKET']
            args = [src, dst, options].compact.join(' ')
            %x(#{"#{aws_cli} s3 cp #{args}"})
            $?.exitstatus == 0
          end
        end

        # Health check methods
        # Read test
        def health_check_R
          %x(#{"#{aws_cli} s3api list-objects --bucket ${MINIO_BUCKET}"})
          $?.exitstatus == 0
        end

        def health_check_W
          args = [
            '--bucket ${MINIO_BUCKET}',
            "--key 'healthcheck_#{Rails.application.class.parent_name}'",
          ].join(' ')

          # Write test
          %x(#{"#{aws_cli} s3api put-object #{args}"})
          $?.exitstatus == 0
        end

        def health_check_D
          args = [
            '--bucket ${MINIO_BUCKET}',
            "--key 'healthcheck_#{Rails.application.class.parent_name}'",
          ].join(' ')

          # Delete test
          %x(#{"#{aws_cli} s3api delete-object #{args}"})
          $?.exitstatus == 0
        end
      end
    end
  end
end
