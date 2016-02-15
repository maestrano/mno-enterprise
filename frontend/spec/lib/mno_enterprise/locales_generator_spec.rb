require 'rails_helper'

module MnoEnterprise::Frontend
  describe LocalesGenerator do


    describe '#generate_json' do
      let(:generator) { described_class.new('tmp/') }
      subject { generator.generate_json }

      it 'is pending'
    end
  end
end
