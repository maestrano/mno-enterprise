json.credit_card do
  if credit_card.try(:id)
    json.presence true
  else
    json.presence false
  end
end
