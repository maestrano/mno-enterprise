require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::AppFeedbacksController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/admin/app_feedbacks')).to route_to("mno_enterprise/jpi/v1/admin/app_feedbacks#index", format: "json")
    end
  end
end