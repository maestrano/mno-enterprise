require 'rails_helper'
require 'cancan/matchers'

# TODO: add more ability tests
RSpec.describe MnoEnterprise::Ability, type: :model do
  subject(:ability) { described_class.new(user, session) }
  let(:session) { {} }
  let(:user) { FactoryGirl.build(:user, admin_role: admin_role) }
  let(:admin_role) { nil }
  let(:organization) { FactoryGirl.build(:organization) }

  before { allow(user).to receive(:role).with(organization) { nil } }

  context 'admin abilities' do
    context 'when User#admin_role is staff' do
      # TODO: Implement full scale staff abilities.
    end

    context 'when User#admin_role is admin' do
      let(:admin_role) { 'admin' }

      it { is_expected.to be_able_to(:manage_app_instances, organization) }

      describe '#create_account_transaction' do
        let(:tenant) { build(:tenant, metadata: { can_manage_organization_credit: can_manage_organization_credit }) }

        context 'with can_manage_organization_credit tenant metadata true' do
          let(:can_manage_organization_credit) { true }
          it { is_expected.to be_able_to(:create_account_transaction, tenant) }
        end

        context 'with can_manage_organization_credit tenant metadata false' do
          let(:can_manage_organization_credit) { false }
          it { is_expected.not_to be_able_to(:create_account_transaction, tenant) }
        end
      end
    end

    context 'when User#admin_role is support' do
      let(:admin_role) { :support }
      let(:session) { { support_org_id: support_org_id } }

      describe 'invoices' do
        context 'with a proper support org id' do
          let(:invoice) { build(:invoice, organization: organization) }
          let(:support_org_id) { organization.id }

          before { allow(invoice).to receive(:organization).and_return(organization) }
          it { is_expected.to be_able_to(:read, invoice) }
        end
      end

      describe 'organizations' do
        context 'with a proper support org id' do
          let(:support_org_id) { organization.id }
          it { is_expected.to be_able_to(:read, organization) }
        end
      end

      describe 'user' do
        let(:user_searched) { build(:user) }
        let(:support_org_id) { organization.id }

        context 'when a user is part of the organization' do
          before { expect(user_searched).to receive(:role).with(MnoEnterprise::Organization.new(id: support_org_id)).and_return(true) }
          it { is_expected.to be_able_to(:read, user_searched) }
        end

        context 'when a user is not part of the organization' do
          before { expect(user_searched).to receive(:role).with(MnoEnterprise::Organization.new(id: support_org_id)).and_return(false) }
          it { is_expected.not_to be_able_to(:read, user_searched) }
        end
      end
    end

    context 'when User#admin_role has a random case' do
      describe '#manage_app_instances' do
        let(:admin_role) { 'ADmIn' }
        it { is_expected.to be_able_to(:manage_app_instances, organization) }
      end
    end
  end

  context 'non-admin abilities' do
    describe '#manage_app_instances' do
      context 'when no User#admin_role' do
        it { is_expected.not_to be_able_to(:manage_app_instances, organization) }
      end
    end
  end
end
