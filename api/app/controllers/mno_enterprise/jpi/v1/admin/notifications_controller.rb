module MnoEnterprise
  class Jpi::V1::Admin::NotificationsController < Jpi::V1::Admin::BaseResourceController

    def index
      @orga_relation_id = MnoEnterprise::OrgaRelation.where(user_id: current_user.id, organization_id: params[:organization_id]).first.id
      @notifications = list_of_notifications
    end

    def update
      object = fetch_object
      notification_type = params[:notification_type]
      case notification_type
      when 'status_change'
        return render_not_found("#{notification_type}") unless object
        object.update(completed_notified_at: Time.new)
      when 'reminder'
        object_recipient = fetch_object_recipient(object)
        return render_not_found("#{notification_type}") unless object_recipient
        object_recipient.update(reminder_notified_at: Time.new)
      when 'due_date'
        object_recipient = fetch_object_recipient(object)
        return render_not_found("#{notification_type}") unless object_recipient
        object.update(read_at: Time.new) if params[:notified]
        object.update(notified_at: Time.new) if params[:notified]
      else
        return render_bad_request("update #{params[:object_type]} notification", object)
      end
      render json: {status:  'Ok'},  status: :updated
    end

    private

    def list_of_notifications
      [reminder, due_date, status_change].flatten
    end

    # Create notifications from objects depending on notification type
    def build_notifications(objects, notification_type)
      case notification_type
      when 'status_change'
        build_status_change(objects)
      when 'reminder'
        build_reminder(objects)
      when 'due_date'
        build_due_date(objects)
      end 
    end
    
    # build due_date notification object
    def build_due_date(objects)
      objects.map do |object| 
        {
          object_id: object.id,
          object_type: object.class.name.split("::").last.downcase,
          title: "Task due #{date(object.due_date)}",
          message: "Title: #{object.title}\n From: #{notification_sender(object)}\n"\
            "See your due tasks for more details"
        }
      end  
    end
    
    # build status_change notification object
    def build_status_change(objects)
      objects.map do |object|
        {
          object_id: object.id,
          object_type: object.class.name.split("::").last.downcase,
          title: 'Task completed',
          message: "#{object.recipients.first[:user][:name]} #{object.recipients.first[:user][:surname]}"\
            "from #{object.recipients.first[:organization][:name]}"\
            "has completed\n the task: #{object.title}.\n See your messages for more details."
        }
      end
    end

    # build reminder notification object
    def build_reminder(objects)
      objects.map do |object|
        {
          object_id: object.id,
          object_type: object.class.name.split("::").last.downcase,
          title: 'Task Reminder',
          message: "Title: #{object.title}\n From: #{notification_sender(object)}\n"\
            "Due date: #{date(object.due_date)}\n See your due tasks for more details"
        }
      end
    end

    def date(date)
      if date.today?
        'today'
      else
        (date).strftime('%a, %d %b %Y')
      end
    end

    def notification_sender(object)
      orga_relation = MnoEnterprise::OrgaRelation.find(object.owner_id)
      "#{orga_relation.user.name} #{orga_relation.user.surname} - #{orga_relation.organization.name}"
    end

    def fetch_object
      # extract the class from params[:object_type]
      klass = "MnoEnterprise::#{params[:object_type].camelize}".constantize
      # retrieve the object
      object ||= klass.find(params[:object_id].to_i)
    end

    def fetch_object_recipient(object)
      orga_relation_id = MnoEnterprise::OrgaRelation.where(user_id: current_user.id, organization_id: parent_organization.id).first.id
      # object's recipient model
      klass = "MnoEnterprise::#{params[:object_type].camelize}Recipient".constantize
      # retrieve the object's recipient
      object ||= klass.where("#{params[:object_type]}_id"=> object.id, 'orga_relation_id'=> orga_relation_id).first
    end

    # Notifications 
    def reminder
      tasks = MnoEnterprise::Task.where('task_recipients.orga_relation_id'=> @orga_relation_id, 'completed_at' => '',
        'task_recipients.reminder_date.ne' => '', 'task_recipients.reminder_notified_at' => '', 'task_recipients.reminder_date.gt' => Time.new)
      build_notifications(tasks, 'reminder')
    end

    def due_date
      tasks = MnoEnterprise::Task.where('task_recipients.orga_relation_id'=> @orga_relation_id, 'due_date.ne' => '',
        'completed_at' => '', 'due_date.gt' => Time.new, 'task_recipients.notified_at' => '')
      build_notifications(tasks, 'due_date')
    end

    def status_change
      tasks = MnoEnterprise::Task.where('task_recipients.orga_relation_id'=> @orga_relation_id, 'completed_at.ne' => '',
        'completed_notified_at' => '')
      build_notifications(tasks, 'status_change')
    end
  end
end
