module MnoEnterprise
  class Jpi::V1::Admin::NotificationsController < Jpi::V1::Admin::BaseResourceController

    # GET mnoe/jpi/v1/admin/notifications
    def index
      orga_relation_id = current_user.organizations.first.orga_relation_id
      return render_bad_request("could not find orga_relation for user #{current_user.id} in organization_id #{params[:organization_id]}", nil) unless orga_relation_id
      @notifications = [
        fetch_reminder_notifications(orga_relation_id),
        fetch_due_date_notifications(orga_relation_id),
        fetch_status_change_notifications(orga_relation_id)
      ].flatten
    end

   # POST mnoe/jpi/v1/admin/notifications/notified
    def notified
      if params[:object_type] == 'task'
        update_task
      else
        return render_bad_request("update, object type do not exist or it is missing", nil)
      end
    end

    private

    # Fetch notifications
    def fetch_reminder_notifications(orga_relation_id)
      tasks = MnoEnterprise::Task.where('task_recipients.orga_relation_id'=> orga_relation_id, 'completed_at' => '',
        'task_recipients.reminder_date.ne' => '', 'task_recipients.reminder_notified_at' => '', 'task_recipients.reminder_date.lt' => Time.new)
      tasks.map do |task|
        {
          object_id: task.id,
          object_type: 'task',
          notification_type: "reminder",
          title: 'Task Reminder',
          message: ["Title: #{task.title}",
            "From: #{format_notification_sender(task)}",
            "Due date: #{format_date(task.due_date)}",
            "See your due tasks for more details"].join("\n")
        }
      end
    end

    def fetch_due_date_notifications(orga_relation_id)
      tasks = MnoEnterprise::Task.where('task_recipients.orga_relation_id'=> orga_relation_id, 'due_date.ne' => '',
        'completed_at' => '', 'due_date.lt' => Time.new, 'task_recipients.notified_at' => '')
      tasks.map do |task|
        {
          object_id: task.id,
          object_type: 'task',
          notification_type: "due_date",
          title: "Task due #{format_date(task.due_date)}",
          message: ["Title: #{task.title}",
            "From: #{format_notification_sender(task)}",
            "See your due tasks for more details"].join("\n")
        }
      end
    end

    def fetch_status_change_notifications(orga_relation_id)
      tasks = MnoEnterprise::Task.where(owner_id: orga_relation_id, 'completed_at.ne' => '',
        'completed_notified_at' => '')
      tasks.map do |task|
        {
          object_id: task.id,
          object_type: 'task',
          notification_type: "status_change",
          title: 'Task completed',
          message: ["#{task.recipients.first[:user][:name]} #{task.recipients.first[:user][:surname]}",
            "#{task.recipients.first[:organization][:name]}",
            "has completed the task: #{task.title}.",
            "See your messages for more details."].join("\n")
        }
      end
    end

    def update_task
      task = MnoEnterprise::Task.find(params[:object_id].to_i)
      return render_not_found("#{notification_type}") unless task
      notification_type = params[:notification_type]
      case notification_type
      when 'status_change'
        task.update(completed_notified_at: Time.new)
      when 'reminder'
        task_recipient = fetch_task_recipient(task)
        return render_not_found("#{notification_type}") unless task_recipient
        task_recipient.update(reminder_notified_at: Time.new)
      when 'due_date'
        task_recipient = fetch_task_recipient(task)
        return render_not_found("#{notification_type}") unless task_recipient
        task_recipient.update(notified_at: Time.new)
      else
        return render_bad_request("update #{params[:object_type]} notification", task)
      end
      head :ok
    end

    def fetch_task_recipient(task)
      orga_relation_id = current_user.organizations.first.orga_relation_id
      MnoEnterprise::TaskRecipient.where("task_id"=> task.id, 'orga_relation_id'=> orga_relation_id).first
    end

    # format notification sender details
    def format_notification_sender(task)
      "#{task[:owner][:user][:name]} #{task[:owner][:user][:surname]} - #{task.owner[:organization][:name]}"
    end

    # format date
    def format_date(date)
      date.today? ? 'today' : date.strftime('%a, %d %b %Y')
    end
  end
end
