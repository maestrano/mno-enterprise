module MnoEnterprise
  class Impac::Widget < BaseResource

  	attributes :name, :width, :widget_category, :settings

    belongs_to :dashboard, class_name: 'MnoEnterprise::Impac::Dashboard'

    def to_audit_event
      name
    end

  end
end
