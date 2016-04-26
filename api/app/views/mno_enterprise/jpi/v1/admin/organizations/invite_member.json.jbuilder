json.user do
  json.partial! 'member', member: @user, organization: @organization
end
