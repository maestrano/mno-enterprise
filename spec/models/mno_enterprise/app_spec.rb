require 'rails_helper'

module MnoEnterprise
  RSpec.describe App, :type => :model do
    
    describe 'sanitized_description' do
      let(:app) { build(:app, description: "Some description by Maestrano") }
      
      it 'replaces any mention of maestrano by the name of the platform' do
        expect(app.sanitized_description).to eq("Some description by #{MnoEnterprise.app_name}")
      end
    end
  end
end
