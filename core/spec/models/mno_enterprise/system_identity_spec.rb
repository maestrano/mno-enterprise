require 'rails_helper'

module MnoEnterprise
  RSpec.describe SystemIdentity, type: :model do
    describe '.table_name' do
      subject { described_class.table_name }

      it { is_expected.to eql('system_identity') }
    end
  end
end
