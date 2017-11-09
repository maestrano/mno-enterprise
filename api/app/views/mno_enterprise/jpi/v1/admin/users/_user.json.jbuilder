json.extract! user, :id, :uid, :email, :phone, :name, :surname, :admin_role, :created_at, :updated_at, :confirmed_at, :last_sign_in_at, :sign_in_count
json.sub_tenant_id user.sub_tenant&.id
json.access_request_status user.access_request_status(current_user)
