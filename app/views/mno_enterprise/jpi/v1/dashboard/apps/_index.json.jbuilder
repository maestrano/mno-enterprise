json.timestamp @new_timestamp

json.set! :app_instances do
  @app_instances.each do |app_instance|
    json.set! "app_instance_#{app_instance.id}" do
      json.partial! 'show', app_instance: app_instance
    end
  end
end
