organization ||= @organization

json.members do
  json.array! [organization.users,organization.orga_invites.active].flatten do |member|
    if member.is_a?(User)
      json.id member.id
      json.entity 'User'
      json.name member.name
      json.surname member.surname
      json.email member.email
      json.role member.role(organization)
    end
    
    if member.is_a?(OrgaInvite)
      json.id member.id
      json.entity 'OrgaInvite'
      json.email member.user_email
      json.role member.user_role
    end
  end
end