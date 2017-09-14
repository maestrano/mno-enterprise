require 'rails_helper'

module MnoEnterprise
  RSpec.describe Impac::Dashboard, type: :model do
    let(:org1) { build(:organization) }
    subject(:dashboard) { build(:impac_dashboard, organization_ids: [org1.uid]) }

    describe '#full_name' do
      subject { dashboard.full_name }
      it { is_expected.to eq(dashboard.name) }
    end

    describe '#filtered_widgets_templates' do
      let(:templates) {
        [
          {path: 'accounts/balance', name: 'Account balance'},
          {path: 'accounts/comparison', name: 'Accounts comparison'}
        ]
      }
      subject(:dashboard) { build(:impac_dashboard, widgets_templates: templates) }

      subject { dashboard.filtered_widgets_templates }

      context 'with no filter' do
        before { MnoEnterprise.widgets_templates_listing = nil}

        it 'returns all the widgets' do
          expect(subject).to eq(templates)
        end
      end

      context 'with a filter' do
        let(:filter) { ['accounts/balance'] }
        before { MnoEnterprise.widgets_templates_listing = filter }

        it 'returns a filtered list' do
          expect(subject.size).to eq(1)
          expect(subject.map{|h| h[:path]}).to eq(filter)
        end
      end
    end

    describe '#organizations(orgs_list)' do
      subject { dashboard.organizations(orgs_list) }

      let(:org2) { build(:organization) }
      let(:orgs_list) { [org1, org2] }

      it { is_expected.to eq([org1]) }

      context 'when the dashboard is a template' do
        let(:dashboard) { build(:impac_dashboard, organization_ids: [org1.uid], dashboard_type: 'template') }

        it { is_expected.to eq([org1, org2]) }
      end
    end
  end
end
