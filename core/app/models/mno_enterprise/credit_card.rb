module MnoEnterprise
  class CreditCard < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    def expiry_date
      year && month && Date.new(year, month).end_of_month
    end
  end
end
