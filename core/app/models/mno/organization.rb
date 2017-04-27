module Mno
  class Organization < BaseResource

    custom_endpoint :app_instances_sync, on: :member, request_method: :get
    custom_endpoint :trigger_app_instances_sync, on: :member, request_method: :post

  end
end
