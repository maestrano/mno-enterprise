json.set! :product_instances do
  @product_instances.each do |product_instance|
    json.set! product_instance.id.to_s do
      json.partial! 'resource', product_instance: product_instance
    end
  end
end
