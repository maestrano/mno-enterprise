json.organization do
  json.partial! 'organization', organization: @organization
  json.members @organization.members, partial: 'member', as: :member, organization: @organization
end
