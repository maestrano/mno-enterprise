json.sub_tenant do
  json.partial! 'sub_tenant', sub_tenant: @sub_tenant

  json.clients @sub_tenant_clients do |org|
    json.id org.id
    json.uid org.uid
    json.name org.name
    json.created_at org.created_at
  end

  json.account_managers @sub_tenant_account_managers do |user|
    json.id user.id
    json.uid user.uid
    json.name user.name
    json.surname user.surname
    json.email user.email
    json.created_at user.created_at
  end

end
