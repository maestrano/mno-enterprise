module MnoEnterprise
  class Alert < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time
    property :kpi_id
    has_one :kpi

    custom_endpoint :update_recipients, on: :member, request_method: :patch

    def self.create_with_recipients!(attributes, recipient_ids)
      alert = create(attributes)
      alert.update_recipients!(recipient_ids)
      alert
    end

    def update_recipients!(ids)
      input = {data: {attributes: {set: ids}}}
      result = update_recipients(input)
      process_custom_result(result)
    end

  end
end
