json.credit_card do
  if credit_card
    json.presence true
    json.updated_at credit_card.updated_at
  else
    json.presence false
  end
end
