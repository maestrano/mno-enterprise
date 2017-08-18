json.notifications do
  json.array! @tasks_to_be_reminded do |task|
    json.object_id task.id
    json.object_type 'task'
    json.notification_type MnoEnterprise::Task::NOTIFICATION_TYPE::REMINDER
    json.title 'Task Reminder'
    json.message ["Title: #{task.title}",
                  "From: #{format_notification_sender(task)}",
                  "Due date: #{format_date(task.due_date)}",
                  'See your due tasks for more details'].join("\n")

  end
  json.array! @due_tasks do |task|
    json.object_id task.id
    json.object_type 'task'
    json.notification_type MnoEnterprise::Task::NOTIFICATION_TYPE::DUE
    json.title "Task due #{format_date(task.due_date)}"
    json.message ["Title: #{task.title}",
                  "From: #{format_notification_sender(task)}",
                  'See your due tasks for more details'].join("\n")

  end
  json.array! @completed_tasks do |task|
    recipient = task.task_recipients.first
    json.object_id task.id
    json.object_type 'task'
    json.notification_type MnoEnterprise::Task::NOTIFICATION_TYPE::COMPLETED
    json.title 'Task completed'
    json.message (["#{recipient[:user][:name]} #{recipient[:user][:surname]}",
                   "#{recipient[:organization][:name]}",
                   "has completed the task: #{task.title}.",
                   'See your messages for more details.'].join("\n"))
  end
end
