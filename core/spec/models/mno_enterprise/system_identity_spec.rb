require 'rails_helper'

module MnoEnterprise
  RSpec.describe SystemIdentity, type: :model do
    subject { described_class.table_name }

    describe '.table_name' do
      it { is_expected.to eql('system_identity') }
    end
  end
end
