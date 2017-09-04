module MnoEnterprise::TestingSupport::SharedExamples::Plugins
  shared_examples MnoEnterprise::Plugins::Base do
    it { expect(described_class).to respond_to(:json_schema) }

    describe 'instance methods' do
      let(:tenant) { build(:tenant) }
      let(:config) { {} }
      subject { described_class.new(tenant, config) }

      it { is_expected.to respond_to(:save) }
    end
  end
end
