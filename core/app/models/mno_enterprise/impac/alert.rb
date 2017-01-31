module MnoEnterprise
  class Impac::Alert < BaseResource

    attributes :title, :webhook, :service, :settings, :sent, :recipients

    belongs_to :kpi, class_name: 'MnoEnterprise::Impac::Kpi', foreign_key: 'impac_kpi_id'

  end
end
