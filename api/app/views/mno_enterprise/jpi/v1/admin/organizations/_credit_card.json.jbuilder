json.credit_card do
  if credit_card
    json.presence true
    json.extract! credit_card, :updated_at
  else
    json.presence false
  end
end
