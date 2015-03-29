# == Schema Information
#
# Endpoint:
#  - /v1/org_invites
#  - /v1/organizations/:organization_id/org_invites
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  user_email      :string(255)
#  organization_id :integer
#  referrer_id     :integer
#  token           :string(255)
#  status          :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  user_role       :string(255)
#  team_id         :integer
#

module MnoEnterprise
  class OrgInvite < BaseResource
    
    #==============================================================
    # Associations
    #==============================================================
    belongs_to :user, class_name: 'MnoEnterprise::User'
    belongs_to :referrer, class_name: 'MnoEnterprise::User'
    belongs_to :organization, class_name: 'MnoEnterprise::Organization'
    belongs_to :team, class_name: 'MnoEnterprise::OrgTeam'
    
  end
end