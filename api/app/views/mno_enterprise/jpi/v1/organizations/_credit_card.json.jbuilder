json.credit_card do
  if credit_card
    json.extract! credit_card, :id, :title,:first_name,:last_name,:month,:year,:country,:billing_address,:billing_city,:billing_postcode, :billing_country
    json.number credit_card.masked_number
    json.verification_value credit_card.id ? 'CVV' : nil
  end
end
