require 'rails_helper'

describe MnoEnterprise do
  
  describe 'configure' do
    it 'yields self' do
      MnoEnterprise.configure { |config| expect(config).to eq(MnoEnterprise) }
    end
  end
  
end