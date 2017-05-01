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

    describe '#has_credit_card_details?' do
      let(:organization) { FactoryGirl.build(:organization) }
      subject { organization.has_credit_card_details? }

      context 'with a credit card' do
        before { organization.credit_card = FactoryGirl.build(:credit_card) }
        it { is_expected.to be true }
      end

      context 'without a credit card' do
        # Her return a new object if non existing
        before { organization.credit_card = MnoEnterprise::CreditCard.new }
        it { is_expected.to be false }
      end
    end
  end
end
