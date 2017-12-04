require 'rails_helper'
require 'cancan/matchers'

# TODO: add more ability tests
RSpec.describe MnoEnterprise::Ability, type: :model do
  subject(:ability) { described_class.new(user) }
  let(:user) { build(:user, admin_role: admin_role) }
  let(:admin_role) { nil }
  let(:orga_relation) { build(:orga_relation, role: 'Member') }
  context 'when User#admin_role is admin' do
    let(:admin_role) { 'admin' }
    it { is_expected.to be_able_to(:manage_app_instances, orga_relation) }
  end

  context 'when User#admin_role has a random case' do
    let(:admin_role) { 'ADmIn' }
    it { is_expected.to be_able_to(:manage_app_instances, orga_relation) }
  end

  context 'when no User#admin_role' do
    it { is_expected.not_to be_able_to(:manage_app_instances, orga_relation) }
  end
end
