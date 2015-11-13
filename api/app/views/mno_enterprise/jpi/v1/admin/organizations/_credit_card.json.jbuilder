json.credit_card do
  if credit_card
    json.presence "true"
  else
    json.presence "false"
  end
end