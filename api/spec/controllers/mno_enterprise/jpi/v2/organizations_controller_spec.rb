require 'rails_helper'

module MnoEnterprise
  describe Jpi::V2::OrganizationsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV2ApiController

    it_behaves_like MnoEnterprise::Jpi::V2::ApiController
  end
end
