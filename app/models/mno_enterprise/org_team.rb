# == Schema Information
#
# Endpoint:
#  - /v1/org_teams
#  - /v1/organizations/:organization_id/org_teams
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  organization_id :integer
#

module MnoEnterprise
  class OrgTeam < BaseResource
    
    attributes :id, :name, :organization_id
    
    #=====================================
    # Associations
    #=====================================
    belongs_to :organization, class_name: 'MnoEnterprise::Organization'
  end
end