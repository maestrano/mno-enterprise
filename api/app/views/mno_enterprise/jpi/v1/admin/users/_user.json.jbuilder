json.extract! user, :id, :uid, :email, :phone_country_code, :phone, :name, :surname, :admin_role,
  :created_at, :updated_at, :confirmed_at, :last_sign_in_at, :sign_in_count, :locked_at, :failed_attempts,
  :locked_at, :password_changed_at, :geo_country_code, :geo_state_code, :geo_city, :geo_currency
json.access_locked user.access_locked?
json.sub_tenant_id user.sub_tenant&.id
json.access_request_status user.access_request_status(current_user)
