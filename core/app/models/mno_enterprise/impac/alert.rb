module MnoEnterprise
  class Impac::Alert < BaseResource

    attributes :title, :webhook, :service, :settings, :sent

    belongs_to :kpi, class_name: 'MnoEnterprise::Impac::Kpi', foreign_key: 'impac_kpi_id'
    has_many :recipients, class_name: 'MnoEnterprise::User'

  end
end
