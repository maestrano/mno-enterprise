require 'rails_helper'

module MnoEnterprise
  RSpec.describe Subscription, type: :model do
    %w(modify change suspend renew reactivate cancel).each do |action|
      describe "##{action}" do
        let(:subscription) { build(:subscription) }

        before { stub_api_v2(:post, "/subscriptions/#{subscription.id}/#{action}", nil) }

        subject { subscription.send(action) }

        it "calls #{action} on the subscription" do
          subject
          assert_requested_api_v2(:post, "/subscriptions/#{subscription.id}/#{action}", body: {}.to_json)
        end
      end
    end
  end
end
