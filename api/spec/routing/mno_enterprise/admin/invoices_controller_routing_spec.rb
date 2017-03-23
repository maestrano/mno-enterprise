require "rails_helper"

module MnoEnterprise
  RSpec.describe Admin::InvoicesController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it "routes to #show" do
      expect(get("/admin/invoices/201504-NU4")).to route_to("mno_enterprise/admin/invoices#show", id: '201504-NU4')
    end
  end
end
