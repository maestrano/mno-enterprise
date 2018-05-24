json.id product_instance.id
json.uid product_instance.uid
json.name product_instance.product.name
json.status product_instance.status
json.created_at product_instance.created_at
json.sync_status product_instance.sync_status

# Note: Handles tiny_description, getting_started, support_url from product#values
product_instance.product.values.tap do |value|
  json.value&.field&.nid value&.data
end

product_instance.product.tap do |product|
  json.product_id product.id
  json.product_name product.name
  json.product_nid product.nid
  json.logo product.logo
  json.data_sharing product.data_sharing_enabled
  json.add_on product.is_connector_framework
end

# TODO: This is a temporary mapping of values that are not currently available
#       in products or are depreciated. They need to be updated when added to
#       products or are permanently depreciated.
json.stack product_instance.app_instance&.stack
json.oauth_keys_valid product_instance.app_instance&.oauth_keys_valid
json.per_user_licence product_instance.app_instance&.per_user_licence

if product_instance.app_instance&.oauth_company
  json.oauth_company_name product_instance.app_instance&.oauth_company
end
