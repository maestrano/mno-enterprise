module MnoEnterprise
  class Impac::Alert < BaseResource

    attributes :title, :webhook, :service, :metadata, :sent

    belongs_to :kpi, class_name: 'MnoEnterprise::Impac::Kpi'
    has_many :recipients, class_name: 'MnoEnterprise::User'

  end
end
