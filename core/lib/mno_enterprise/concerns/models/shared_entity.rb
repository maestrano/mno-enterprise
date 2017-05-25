# frozen_string_literal: true
# == Schema Information
#
# Endpoint:
#  - /v1/app/:app_id/shared_entities
#
#  id                :integer         not null, primary key
#  nid               :string
#  name              :string
#  created_at        :datetime        not null
#  updated_at        :datetime        not null

module MnoEnterprise::Concerns::Models::SharedEntity
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  included do
    # == Relationships ==============================================
    belongs_to :app
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
