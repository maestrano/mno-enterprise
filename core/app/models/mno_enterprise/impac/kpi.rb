module MnoEnterprise
  class Impac::Kpi < BaseResource

    attributes :settings, :targets, :extra_params, :endpoint, :source, :element_watched, :extra_watchables

    belongs_to :dashboard, class_name: 'MnoEnterprise::Impac::Dashboard'
    belongs_to :widget, class_name: 'MnoEnterprise::Impac::Widget'
    has_many :alerts, class_name: 'MnoEnterprise::Impac::Alert'

    def organizations(orgs = nil)
      if orgs.present?
        orgs.select { |org| organization_ids.include?(org.uid) }.to_a
      else
        MnoEnterprise::Organization.where('uid.in' => organization_ids).to_a
      end
    end

    private

    def organization_ids
      @organization_ids ||= (settings.present? && settings['organization_ids']).to_a
    end
  end
end
