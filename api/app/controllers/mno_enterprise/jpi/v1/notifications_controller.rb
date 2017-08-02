module MnoEnterprise
  class Jpi::V1::NotificationsController < Jpi::V1::BaseResourceController

    def index
      @orga_relation_id = MnoEnterprise::OrgaRelation.where(user_id: current_user.id, organization_id: params[:organization_id]).first.id
      @reminders = reminders
      @due_date = due_date
      @status_change = status_change
    end

    def reminders
      MnoEnterprise::Task.where('task_recipients.orga_relation_id'=> @orga_relation_id, 'completed_at' => '',
        'task_recipients.reminder_date.ne' => '', 'task_recipients.reminder_notified_at' => '', 'task_recipients.reminder_date.gt' => Time.new)
    end

    def due_date
      MnoEnterprise::Task.where('task_recipients.orga_relation_id'=> @orga_relation_id, 'due_date.ne' => '',
        'completed_at' => '', 'due_date.gt' => Time.new, 'task_recipients.notified_at' => '')
    end

    def status_change
      MnoEnterprise::Task.where('task_recipients.orga_relation_id'=> @orga_relation_id, 'completed_at.ne' => '',
       'completed_notified_at' => '')
    end
  end
end

