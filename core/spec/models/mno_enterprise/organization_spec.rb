require 'rails_helper'

module MnoEnterprise
  RSpec.describe Organization, type: :model do
    describe '#payment_restriction' do
      let(:organization) { FactoryGirl.build(:organization) }
      subject { organization.payment_restriction }

      context 'without metadata' do
        it { is_expected.to be nil }
      end

      context 'without payment restriction' do
        before { organization.meta_data = {} }
        it { is_expected.to be nil }
      end

      context 'with payment restriction' do
        before { organization.meta_data = {payment_restriction: ['visa']} }
        it { is_expected.to eq(['visa']) }
      end
    end
  end
end
