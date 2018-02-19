require 'rails_helper'

module MnoEnterprise
  RSpec.describe Dashboard, type: :model do
    let(:org1) { build(:organization) }
    subject(:dashboard) { build(:impac_dashboard, organization_ids: [org1.uid]) }

    describe '#full_name' do
      subject { dashboard.full_name }
      it { is_expected.to eq(dashboard.name) }
    end

    describe '#sorted_widgets' do
      let(:w1) { build(:impac_widget) }
      let(:w2) { build(:impac_widget) }
      let(:w3) { build(:impac_widget) }

      let(:dashboard) { build(:impac_dashboard, organization_ids: [org1.uid], widgets: [w1, w2, w3]) }

      subject { dashboard.sorted_widgets }

      context 'without #widgets_order' do
        it { is_expected.to eq([w1, w2, w3])}
      end

      context 'with a #widget_order' do
        before { dashboard.widgets_order = [w3.id, w2.id]}
        # unsorted widgets at the end
        it { is_expected.to eq([w3, w2, w1])}

        context 'APIv1 backward compatibility' do
          # APIv1 widgets have integer id
          before { dashboard.widgets_order = [w3.id.to_i, w2.id.to_i]}
          # unsorted widgets at the end
          it { is_expected.to eq([w3, w2, w1])}
        end
      end
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
