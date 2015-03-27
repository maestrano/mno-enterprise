app_instance ||= @app_instance

json.timestamp @new_timestamp if show_timestamp

if app_instance
  json.ownerType app_instance.owner.class.to_s
  json.ownerId app_instance.owner.id
  json.appName app_instance.name

  json.set! :currentPlan do
    if app_instance.app_template
      json.name app_instance.app_template.name
      json.id app_instance.app_template.id
    end
  end

  json.currentBillingType app_instance.billing_type

  json.set! :plans do
    json.array! app_instance.app.app_templates.active do |app_template|
      json.id app_template.id
      json.name app_template.name
    end
  end
end

