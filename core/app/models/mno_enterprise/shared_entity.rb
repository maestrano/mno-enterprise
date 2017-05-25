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

module MnoEnterprise
  class SharedEntity < BaseResource
    include MnoEnterprise::Concerns::Models::SharedEntity
  end
end
