module MnoEnterprise
  class Jpi::V1::NotificationsController < Jpi::V1::BaseResourceController

    def index
      @orga_relation_id = MnoEnterprise::OrgaRelation.where(user_id: current_user.id, organization_id: params[:organization_id]).first.id
      @notifications = list_of_notifications
    end

    def update
      object = fetch_object
      # current user created the notification
      return render_not_found('notification') unless @object
      update_notification(object)
      render json: {status:  'Ok'},  status: :updated
    end

    private

    def list_of_notifications
      [reminders, due_date, status_change].flatten
    end

    # Create notifications from objects
    def build_notifications(objects, notifiction_type)
      objects.map { |object| { object_id: object.id, object_type: object.class.name.split("::").last.downcase, tittle: object.title,
        message: object.message, notifiction_type: notifiction_type, due_date: object.due_date} }
    end

    def is_owner_notification
      @orga_relation_id = MnoEnterprise::OrgaRelation.where(user_id: current_user.id, organization_id: parent_organization.id).first.id
      @orga_relation_id == @object.owner_id
    end

    def fetch_object
      # extract the class from params[:object_type]
      klass = "MnoEnterprise::#{params[:object_type].camelize}".constantize
      # retrieve the objects base on the klass
      @object ||= klass.find(params[:object_id].to_i)
      return @object if @object && is_owner_notification
      return false unless @object
      fetch_object_recipient
    end

    def fetch_object_recipient
      # object's recipient model
      klass = "MnoEnterprise::#{params[:object_type].camelize}Recipient".constantize
      # retrieve the object's recipient
      @object ||= klass.where("#{params[:object_type]}_id"=> @object.id, 'orga_relation_id'=> @orga_relation_id).first
    end

    def update_notification(object)
      # param for object owner
      object.update(completed_notified_at: Time.new) if params[:completed_notified]
      # params for recipient
      object.update(read_at: Time.new) if params[:read]
      object.update(notified_at: Time.new) if params[:notified]
      object.update(reminder_notified_at: Time.new) if params[:reminder_notified]
    end

    # Task notifications 
    def reminders
      tasks = MnoEnterprise::Task.where('task_recipients.orga_relation_id'=> @orga_relation_id, 'completed_at' => '',
        'task_recipients.reminder_date.ne' => '', 'task_recipients.reminder_notified_at' => '', 'task_recipients.reminder_date.gt' => Time.new).fetch    
      build_notifications(tasks, 'reminders')
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
