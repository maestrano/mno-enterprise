json.main_address_attributes do
  if main_address
    json.extract! main_address, :id, :street, :city, :state_code, :postal_code, :country_code, :phone
  end
end
