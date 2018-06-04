require 'rails_helper'

module MnoEnterprise
  RSpec.describe Subscription, type: :model do
    %w(modify change suspend renew reactivate cancel).each do |action|
      describe "##{action}" do
        subject { subscription.public_send(action) }

        let(:subscription) { build(:subscription) }
        let!(:stub) { stub_api_v2(:post, "/subscriptions/#{subscription.id}/#{action}", nil) }

        it "calls #{action} on the subscription" do
          subject
          expect(stub).to have_been_requested
        end
      end
    end
  end
end
