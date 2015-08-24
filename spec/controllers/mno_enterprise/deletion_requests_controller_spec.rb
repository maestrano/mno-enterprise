require 'rails_helper'

module MnoEnterprise
  describe DeletionRequestsController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    describe "GET #show'" do
      # let!(:deletion_req) { MnoEnterprise::DeletionRequest.create(deletable: user) }
      let(:deletion_req) { build(:invoice, organization_id: organization.id) }

    end
  end
end
