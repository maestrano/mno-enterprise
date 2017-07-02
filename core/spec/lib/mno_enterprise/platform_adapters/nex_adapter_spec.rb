# frozen_string_literal: true
require "rails_helper"

describe MnoEnterprise::PlatformAdapters::NexAdapter do
  # TODO: shared example? "it_behave_likes MnoEnterprise::PlatformAdapters::Adapter"
  it { expect(described_class).to respond_to(:restart) }

  around do |example|
    env_vars = {
      MINIO_URL: 'http://minio.test/',
      MINIO_BUCKET: 'test-bucket',
      MINIO_ACCESS_KEY: 'access_key',
      MINIO_SECRET_KEY: 'secret_key',
    }

    with_modified_env(env_vars) do
      example.run
    end
  end

  let(:aws_cmd) { "AWS_ACCESS_KEY_ID=${MINIO_ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${MINIO_SECRET_KEY} aws --endpoint-url ${MINIO_URL}" }
  let(:logo_file) { Rails.root.join('app', 'assets', 'images', 'mno_enterprise', 'main-logo.png') }

  describe '.restart' do
    it 'restarts the app'
  end

  describe '.publish_assets' do
    subject { described_class.publish_assets }

    it 'save the assets to the S3 bucket' do
      expect(described_class).to receive(:`).with("#{aws_cmd} s3 sync #{Rails.root.join('public')} s3://${MINIO_BUCKET}/public/ --delete")
      expect(described_class).to receive(:`).with("#{aws_cmd} s3 sync #{Rails.root.join('frontend', 'src')} s3://${MINIO_BUCKET}/frontend/ --delete")
      expect(described_class).to receive(:`).with("#{aws_cmd} s3 cp #{logo_file} s3://${MINIO_BUCKET}/assets/main-logo.png")
      subject
    end
  end

  describe '.fetch_assets' do
    subject { described_class.fetch_assets }

    it 'fetch the assets from the S3 bucket' do
      expect(described_class).to receive(:`).with("#{aws_cmd} s3 sync s3://${MINIO_BUCKET}/public/ #{Rails.root.join('public')} --exact-timestamps")
      expect(described_class).to receive(:`).with("#{aws_cmd} s3 sync s3://${MINIO_BUCKET}/frontend/ #{Rails.root.join('frontend', 'src')} --exact-timestamps")
      expect(described_class).to receive(:`).with("#{aws_cmd} s3 cp s3://${MINIO_BUCKET}/assets/main-logo.png #{logo_file}")
      subject
    end
  end

  describe '.add_ssl_certs' do
    it 'adds SSL certificates'
  end
end

