# == Schema Information
#
# Endpoint:
#  - /v1/teams
#  - /v1/organizations/:organization_id/teams
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  organization_id :integer
#

module MnoEnterprise
  class Team < BaseResource
    include MnoEnterprise::Concerns::Models::Team
  end
end
