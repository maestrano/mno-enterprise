# == Schema Information
#
# Table name: deletion_requests
#
#  id             :integer         not null, primary key
#  token          :string(255)
#  status         :string(255)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#
require 'rails_helper'

module MnoEnterprise
  RSpec.describe DeletionRequest, type: :model do
    describe 'Instance methods' do
      let(:deletion_request) { build(:deletion_request, token: '1sd5f323S1D5AS') }
      describe '#to_param' do
        it "returns the deletion_request token" do
          expect(deletion_request.to_param).to eq(deletion_request.token)
        end
      end
    end
  end
end
