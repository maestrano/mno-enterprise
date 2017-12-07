require 'rails_helper'
require 'cancan/matchers'

# TODO: add more ability tests
RSpec.describe MnoEnterprise::Ability, type: :model do
  subject(:ability) { described_class.new(user, session) }
  let(:user) { FactoryGirl.build(:user, admin_role: admin_role) }
  let(:user2) { FactoryGirl.build(:user) }
  let(:session) { { impersonator_user_id: user2.id } }
  let(:admin_role) { nil }
  let(:organization) { FactoryGirl.build(:organization) }
  
  let(:org1) { FactoryGirl.build(:organization, acl: acl) }
  let(:org2) { FactoryGirl.build(:organization, acl: acl) }
  let(:acl) do
    {
      self: { show: false, update: false, destroy: false },
      related: {
        impac: { show: false },
        dashboards: { show: false, create: false, update: false, destroy: false },
        widgets: { show: false, create: false, update: false, destroy: false },
        kpis: { show: false, create: false, update: false, destroy: false },
      }
    }
  end
  let(:orgs_with_acl) { [org1, org2] }
  let(:orgs_ids) { orgs_with_acl.map(&:uid) }

  before do
    allow(user).to receive(:role).with(organization) { nil }
    allow(user).to receive(:organizations).and_return(
      double(:active, active: double(:include_acl, include_acl: orgs_with_acl))
    )
  end

  context 'when User#admin_role is admin' do
    let(:admin_role) { 'admin' }
    it { is_expected.to be_able_to(:manage_app_instances, organization) }
  end

  context 'when User#admin_role has a random case' do
    let(:admin_role) { 'ADmIn' }
    it { is_expected.to be_able_to(:manage_app_instances, organization) }
  end

  context 'when no User#admin_role' do
    it { is_expected.not_to be_able_to(:manage_app_instances, organization) }
  end

  describe 'Impac! abilities' do
    %i(dashboards widgets kpis).each do |component|
      %i(create update destroy).each do |action|
        context "when at least one organization cannot #{action} #{component}" do
          before { org1.acl[:related][component][action] = true }

          it do
            impac_component = FactoryGirl.build(
              "impac_#{component}".singularize.to_sym,
              settings: { organization_ids: orgs_ids },
              organization_ids: orgs_ids
            )
            is_expected.not_to be_able_to("#{action}_impac_#{component}".to_sym, impac_component)
          end
        end

        context "when all the organizations can #{action} #{component}" do
          before do
            org1.acl[:related][component][action] = true
            org2.acl[:related][component][action] = true
          end

          it do
            impac_component = FactoryGirl.build(
              "impac_#{component}".singularize.to_sym,
              settings: { organization_ids: orgs_ids },
              organization_ids: orgs_ids
            )
            is_expected.to be_able_to("#{action}_impac_#{component}".to_sym, impac_component)
          end
        end
      end
    end
  end
end
