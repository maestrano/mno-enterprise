json.timestamp Time.now.to_i

json.set! :app_instances do
  @app_instances.each do |app_instance|
    json.set! app_instance.id.to_s do
      json.partial! 'resource', app_instance: app_instance
    end
  end
end
