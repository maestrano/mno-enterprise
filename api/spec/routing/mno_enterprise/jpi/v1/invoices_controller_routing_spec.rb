require "rails_helper"

module MnoEnterprise
  RSpec.describe Jpi::V1::InvoicesController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it "routes to #show" do
      expect(get("/jpi/v1/invoices/201504-NU4")).to route_to("mno_enterprise/jpi/v1/invoices#show", id: '201504-NU4')
    end
  end
end
