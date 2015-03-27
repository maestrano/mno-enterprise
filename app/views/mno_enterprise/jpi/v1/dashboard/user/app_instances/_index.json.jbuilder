json.timestamp @new_timestamp.to_i
json.app_instances do
  @app_instances.each do |app_instance|
    json.set! "app_instance_#{app_instance.id}" do
      json.partial! 'show', app_instance: app_instance
    end
  end
end
