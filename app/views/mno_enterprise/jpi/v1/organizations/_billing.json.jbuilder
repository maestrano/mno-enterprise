json.billing do
  json.current AccountingjsSerializer.serialize(organization.current_billing)
  json.credit AccountingjsSerializer.serialize(organization.current_credit)
end