json.organization do
  json.partial! 'organization', organization: @organization
  json.members @organization.members, partial: 'member', as: :member, organization: @organization
  json.partial! 'credit_card', credit_card: @organization.credit_card
  json.partial! 'invoices', organization: @organization
  json.active_apps @organization_active_apps
end
