json.main_address do
  if main_address
    json.extract! main_address, :id, :street, :city, :state_code, :postal_code, :country_code, :updated_at
  end
end
