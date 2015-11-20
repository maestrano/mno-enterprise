json.in_arrears do
  json.array!(@arrears) do |arrear|
    json.name arrear.name
    json.amount AccountingjsSerializer.serialize(arrear.payment) if arrear.payment
    json.category arrear.category
    json.status arrear.status
  end
end
