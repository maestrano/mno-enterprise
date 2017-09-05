require "rails_helper"

module MnoEnterprise
  RSpec.describe InvoicesController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it "routes to #show" do
      expect(get("/invoices/201504-NU4")).to route_to("mno_enterprise/invoices#show", id: '201504-NU4')
    end
  end
end
