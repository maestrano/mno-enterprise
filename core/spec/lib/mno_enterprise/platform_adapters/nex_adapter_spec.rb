# frozen_string_literal: true
require "rails_helper"

describe MnoEnterprise::PlatformAdapters::NexAdapter do
  include MnoEnterprise::TestingSupport::SharedExamples::PlatformAdapter

  it_behaves_like MnoEnterprise::PlatformAdapters::Adapter

  around do |example|
    env_vars = {
      # Nex!™ self control vars
      SELF_NEX_API_ENDPOINT: 'http://nex.test/',
      SELF_NEX_APP_ID: 'nex-app-id',
      SELF_NEX_API_KEY: 'nex-api-key',

      # Nex!™ Minio addon vars
      MINIO_URL: 'http://minio.test/',
      MINIO_BUCKET: 'test-bucket',
      MINIO_ACCESS_KEY: 'access_key',
      MINIO_SECRET_KEY: 'secret_key'
    }

    with_modified_env(env_vars) do
      example.run
    end
  end

  context 'Assets Operation' do
    let(:aws_cmd) { "AWS_ACCESS_KEY_ID=${MINIO_ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${MINIO_SECRET_KEY} aws --endpoint-url ${MINIO_URL}" }
    let(:logo_file) { Rails.root.join('app', 'assets', 'images', 'mno_enterprise', 'main-logo.png') }

    # Stub system calls
    before { allow(described_class).to receive(:`) }

    # Stub Rake tasks
    # We have to manually redefine all used tasks
    let(:rake) { Rake::Application.new }
    before do
      Rake.application = rake
      Rake::Task.define_task('mnoe:frontend:previewer:build')
    end

    describe '.publish_assets' do
      subject { described_class.publish_assets }

      it 'save the assets to the S3 bucket' do
        default_opts = "--exclude '*' --delete"

        # Public
        opts = "#{default_opts} --include 'dashboard/styles/theme-previewer.less' --include 'dashboard/styles/app-*.css' --include '*/main-logo.png'"
        expect(described_class).to receive(:`).with("#{aws_cmd} s3 sync #{Rails.root.join('public')} s3://${MINIO_BUCKET}/public/ #{opts}")

        # Frontend
        opts = "#{default_opts} --include 'app/stylesheets/theme-previewer-*.less' --include 'images/main-logo.png'"
        expect(described_class).to receive(:`).with("#{aws_cmd} s3 sync #{Rails.root.join('frontend', 'src')} s3://${MINIO_BUCKET}/frontend/ #{opts}")

        # Logo
        expect(described_class).to receive(:`).with("#{aws_cmd} s3 cp #{logo_file} s3://${MINIO_BUCKET}/assets/main-logo.png")

        subject
      end
    end

    describe '.fetch_assets' do
      subject { described_class.fetch_assets }

      it 'fetch the assets from the S3 bucket' do
        expect(described_class).to receive(:`).with("#{aws_cmd} s3 sync s3://${MINIO_BUCKET}/public/ #{Rails.root.join('public')} --exact-timestamps --exclude 'public/dashboard/index.html'")
        expect(described_class).to receive(:`).with("#{aws_cmd} s3 sync s3://${MINIO_BUCKET}/frontend/ #{Rails.root.join('frontend', 'src')} --exact-timestamps")
        expect(described_class).to receive(:`).with("#{aws_cmd} s3 cp s3://${MINIO_BUCKET}/assets/main-logo.png #{logo_file}")
        subject
      end

      it 'rebuild the theme' do
        expect(rake['mnoe:frontend:previewer:build']).to receive(:invoke)
        subject
      end
    end
  end

  context 'NexClient operations' do
    let(:nex_app) { NexClient::App.new(id: 'nex-app-id') }

    before do
      allow(NexClient::App).to receive(:find).with('nex-app-id').and_return([nex_app])
    end

    describe '.restart' do
      it 'restarts the app'
    end

    describe '.update_domain' do
      before  { allow_any_instance_of(NexClient::Domain).to receive(:save).and_return(true) }

      let(:domain) { 'foo.example.test' }
      subject { described_class.update_domain(domain) }

      it 'add a domain to the Nex!™ app' do
        nex_domain = subject
        app = nex_domain.relationships.origin[:data]

        expect(nex_domain.cname).to eq(domain)
        expect(app).to eq({'type' => 'apps', 'id' => 'nex-app-id'})
      end
    end

    describe '.add_ssl_certs' do
      before { allow_any_instance_of(NexClient::SslCertificate).to receive(:save).and_return(true) }

      let(:params) {
        %w(foo.example.test public-cert cert-bundle private-key)
      }
      subject { described_class.add_ssl_certs(*params) }

      it 'adds SSL certificates' do
        nex_cert = subject
        app = nex_cert.relationships.origin[:data]

        expect(app).to eq({'type' => 'apps', 'id' => 'nex-app-id'})
      end
    end
  end

  describe '.health_check' do
    let(:aws_cmd) { "AWS_ACCESS_KEY_ID=${MINIO_ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${MINIO_SECRET_KEY} aws --endpoint-url ${MINIO_URL}" }

    # Stub system calls
    before { allow(described_class).to receive(:`) }

    subject { described_class.health_check }

    it { is_expected.to eq('') }

    it 'tests read permission' do
      expect(described_class).to receive(:`).with("#{aws_cmd} s3api list-objects --bucket ${MINIO_BUCKET}")
      subject
    end

    it 'tests write permission' do
      expect(described_class).to receive(:`).with("#{aws_cmd} s3api put-object --bucket ${MINIO_BUCKET} --key 'healthcheck_Dummy'")
      subject
    end

    it 'tests delete permission' do
      expect(described_class).to receive(:`).with("#{aws_cmd} s3api delete-object --bucket ${MINIO_BUCKET} --key 'healthcheck_Dummy'")
      subject
    end

    context 'error' do
      before { allow(described_class).to receive(:health_check_R).and_raise('some error') }
      it 'raise an error' do
        expect { subject }.to raise_error('permission:R - some error')
      end
    end
  end
end

