json.organization do
  json.partial! 'organization', organization: @organization
  json.members @organization.members, partial: 'member', as: :member, organization: @organization
  json.partial! 'credit_card', credit_card: @organization.credit_card
  json.partial! 'invoices', organization: @organization
  json.active_apps @organization_active_apps do |instance|
    json.extract! instance, :id, :name, :stack, :uid, :status, :oauth_keys_valid
    json.app_name instance.app.name
    json.app_logo instance.app.logo
  end
end
