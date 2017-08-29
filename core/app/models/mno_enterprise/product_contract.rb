module MnoEnterprise
  class ProductContract < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    property :name, description: 'Name of the Contract'
    property :minimum_duration, description: 'Contract minimum duration'
    property :minimum_duration_unit, description: 'Contract minimum duration unit (days, weeks, months)'
    property :cancellation_period, description: 'Contract cancellation period from start date'
    property :cancellation_period_unit, description: 'Contract cancellation period unit'
    property :fees, description: 'Contract cancellation fees', example: "[{ 'currency' => 'USD', 'price_cents' => 995 }, { 'currency' => 'EUR', 'price_cents' => 795 }]"

    def to_audit_event
      {
        id: id,
        name: name
      }
    end
  end
end
