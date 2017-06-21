module MnoEnterprise::Concerns::Models::AppSharedEntity
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  included do
    property :created_at, type: :time
    property :updated_at, type: :time
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
end
