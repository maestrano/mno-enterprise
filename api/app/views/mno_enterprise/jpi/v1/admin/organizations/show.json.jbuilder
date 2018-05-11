json.organization do
  json.partial! 'organization', organization: @organization
  json.members @organization.members(true), partial: 'member', as: :member, organization: @organization
  json.partial! 'credit_card', credit_card: @organization.credit_card
  json.partial! 'invoices', organization: @organization
  json.active_apps @organization_active_apps do |instance|
    json.extract! instance, :id, :name, :stack, :uid, :status, :oauth_keys_valid
    json.app_name instance.app.name
    json.app_logo instance.app.logo
    json.nid instance.app.nid
  end
  json.product_instances @organization_product_instances do |instance|
    json.extract! instance, :id, :uid, :status
    json.nid instance.product.nid
    json.name instance.product.name
    json.logo instance.product.logo
    json.product_type instance.product.product_type
    json.subscriptions do
      json.array! instance.subscriptions&.each do |subscription|
        json.extract! subscription, :id, :status
      end if instance.respond_to?(:subscriptions)
    end
  end
end
