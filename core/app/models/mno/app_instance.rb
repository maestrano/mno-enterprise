module Mno
  class AppInstance < BaseResource
    # PATCH <api_root>/app_instances/:id/terminate
    custom_endpoint :terminate, on: :member, request_method: :patch
    custom_endpoint :provision, on: :collection, request_method: :post
  end
end
