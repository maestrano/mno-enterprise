json.sub_tenant do
  json.partial! 'sub_tenant', sub_tenant: @sub_tenant

  json.clients @sub_tenant_clients do |org|
    json.extract! org, :id, :uid, :name, :created_at
  end

  json.account_managers @sub_tenant_account_managers do |user|
    json.extract! user, :id, :uid, :name, :surname, :email, :created_at, :admin_role
  end

end
