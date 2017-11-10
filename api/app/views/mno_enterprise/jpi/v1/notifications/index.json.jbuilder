json.notifications do
  json.array! @tasks_to_be_reminded do |task|
    json.object_id task.id
    json.object_type 'task'
    json.notification_type MnoEnterprise::Task::NOTIFICATION_TYPE::REMINDER
    json.task do
      json.partial! 'mno_enterprise/jpi/v1/tasks/task', task: task
    end
  end
  json.array! @due_tasks do |task|
  json.object_id task.id
  json.object_type 'task'
  json.notification_type MnoEnterprise::Task::NOTIFICATION_TYPE::DUE
  json.task do
    json.partial! 'mno_enterprise/jpi/v1/tasks/task', task: task
  end
  end
  json.array! @completed_tasks do |task|
    json.object_id task.id
    json.object_type 'task'
    json.notification_type MnoEnterprise::Task::NOTIFICATION_TYPE::COMPLETED
    json.task do
      json.partial! 'mno_enterprise/jpi/v1/tasks/task', task: task
    end
  end
end
