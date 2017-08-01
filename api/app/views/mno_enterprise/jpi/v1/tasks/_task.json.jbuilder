json.extract! task, :id, :owner_id, :title, :message, :send_at, :status, :due_date, :completed_at,
              :completed_notified_at, :created_at, :updated_at
json.owner do
  json.user do
    json.extract! task.owner[:user], :id, :name, :surname, :email
  end
  json.organization do
    json.extract! task.owner[:organization], :id, :name
  end
end

json.task_recipients do
  json.array! task.task_recipients do |recipient|
    json.role recipient.role
    json.id recipient.id
    json.orga_relation_id recipient.orga_relation_id
    json.read_at recipient.read_at
    json.notified_at recipient.notified_at
    json.reminder_date recipient.reminder_date
    json.reminder_notified_at recipient.reminder_notified_at
    json.user do 
      json.extract! recipient.user, :id, :name, :surname, :email
    end
    json.organization do 
      json.extract! recipient.organization, :id, :name
    end
  end
end
