module MnoEnterprise::TestingSupport::SharedExamples::PlatformAdapter
  shared_examples MnoEnterprise::PlatformAdapters::Adapter do
    it { expect(described_class).to respond_to(:restart) }
    it { expect(described_class).to respond_to(:publish_assets) }
    it { expect(described_class).to respond_to(:fetch_assets) }
    it { expect(described_class).to respond_to(:update_domain) }
    it { expect(described_class).to respond_to(:add_ssl_certs) }
    it { expect(described_class).to respond_to(:health_check) }
  end
end
