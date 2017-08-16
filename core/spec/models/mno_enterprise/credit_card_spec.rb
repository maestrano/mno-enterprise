require 'rails_helper'

module MnoEnterprise
  RSpec.describe CreditCard, type: :model do
    describe '#expiry_date' do

      context 'with a valid date' do
        let(:credit_card) { build(:credit_card, year: 2020, month: 5) }
        it { expect(credit_card.expiry_date).to eq(Date.new(2020,5,31)) }
      end

      context 'without a date' do
        let(:credit_card) { build(:credit_card, year: nil, month: nil)}
        it { expect(credit_card.expiry_date).to be nil }
      end
    end
  end
end
