require 'rails_helper'
module MnoEnterprise
  describe TenantReporting, type: :model do
    let(:tenant_reporting) { build(:tenant_reporting) }

    # Test singular resource
    describe '.show' do
      let!(:stub) { stub_api_v2(:get, '/tenant_reporting', tenant_reporting) }
      before { described_class.find.first }
      it { expect(stub).to have_been_requested }
    end
  end
end
