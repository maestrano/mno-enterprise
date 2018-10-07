json.organizations do
  json.array! @organizations do |organization|
    json.partial! 'organization', organization: organization
    json.role @user.role(organization) if @user
    json.partial! 'credit_card', credit_card: organization.credit_card
  end
end
json.metadata @organizations.metadata if @organizations.respond_to?(:metadata)
