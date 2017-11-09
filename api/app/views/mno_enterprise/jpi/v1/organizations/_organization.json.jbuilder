json.extract! organization, :id, :name, :soa_enabled, :payment_restriction, :account_frozen, :orga_relation_id #, :current_support_plan
# json.show_new_db_features !!organization.get_meta_data(:show_new_db_features)
# if organization.support_plan
#   json.custom_training_credits organization.support_plan.custom_training_credits
# end

# json.bootstrap_tasks do
#   json.app_launched (@organization.app_instances.count > 0)
#   json.credit_card_details @organization.credit_card?
#   json.data_uploaded !!@organization.get_meta_data(:data_uploaded)
#   json.colleagues_invited (@organization.orga_invites.count > 0)
#   json.connec_promo !!@organization.get_meta_data(:connec_promo)
# end
