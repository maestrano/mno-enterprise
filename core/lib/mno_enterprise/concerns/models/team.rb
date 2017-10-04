module MnoEnterprise::Concerns::Models::Team
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    property :created_at, type: :time
    property :updated_at, type: :time
    property :organization_id
  end

  #==================================================================
  # Class methods
  #==================================================================
  module ClassMethods
    # def some_class_method
    #   'some text'
    # end
  end

  #==================================================================
  # Instance methods
  #==================================================================
  def to_audit_event
    {
      name: name,
      organization_id: organization_id
    }
  end
end
