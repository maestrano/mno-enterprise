require 'rails_helper'
require 'cancan/matchers'

# TODO: add more ability tests
RSpec.describe MnoEnterprise::Ability, type: :model do
  subject(:ability) { described_class.new(user) }
  let(:user) { FactoryGirl.build(:user, admin_role: admin_role) }
  let(:admin_role) { nil }

  context 'when User#admin_role is admin' do
    let(:admin_role) { 'admin' }
    it { is_expected.to be_able_to(:manage_app_instances, MnoEnterprise::Organization) }
  end
end
