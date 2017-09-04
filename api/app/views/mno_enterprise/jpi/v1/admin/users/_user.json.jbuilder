json.extract! user, :id, :uid, :email, :phone, :name, :surname, :admin_role, :updated_at, :created_at, :confirmed_at, :last_sign_in_at, :sign_in_count, :mnoe_sub_tenant_id, :client_ids
json.access_request_status user.access_request_status(current_user)
