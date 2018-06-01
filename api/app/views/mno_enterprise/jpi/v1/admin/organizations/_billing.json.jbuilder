json.billing do
  json.credit AccountingjsSerializer.serialize(organization.current_credit)
end
