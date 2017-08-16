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
        before { organization.metadata = {} }
        it { is_expected.to be nil }
      end

      context 'with payment restriction' do
        before { organization.metadata = {payment_restriction: ['visa']} }
        it { is_expected.to eq(['visa']) }
      end
    end

    describe '#has_credit_card_details?' do
      let(:credit_card_id){'credit-card-id'}
      let(:organization) { FactoryGirl.build(:organization, credit_card_id: credit_card_id) }
      subject { organization.has_credit_card_details? }

      context 'with a credit card' do
        it { is_expected.to be true }
      end

      context 'without a credit card' do
        let(:credit_card_id){nil}
        it { is_expected.to be false }
      end
    end
  end
end
