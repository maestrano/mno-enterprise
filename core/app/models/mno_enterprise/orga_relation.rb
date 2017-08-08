# frozen_string_literal: true
# == Schema Information
#
# Table name: orga_relations
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  organization_id :integer
#  role            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  metadata        :text
#  position        :string(255)
#  mnoe_tenant_id  :integer
#
module MnoEnterprise
  class OrgaRelation < BaseResource
    #============================================
    # Associations
    #============================================
    belongs_to :user
    belongs_to :organization
  end
end
