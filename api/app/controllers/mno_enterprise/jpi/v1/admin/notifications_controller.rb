module MnoEnterprise
  class Jpi::V1::Admin::NotificationsController < Jpi::V1::Admin::BaseResourceController

    helper_method :format_notification_sender, :format_date

    # GET mnoe/jpi/v1/admin/notifications
    def index
      @tasks_to_be_reminded = MnoEnterprise::Task.recipient(orga_relation_id).sent.to_be_reminded.order('due_date DESC')
      @due_tasks = MnoEnterprise::Task.recipient(orga_relation_id).sent.due.order('due_date DESC')
      @completed_tasks = MnoEnterprise::Task.owner(orga_relation_id).done.completed.order('due_date DESC')
      render template: 'mno_enterprise/jpi/v1/notifications/index'
    end

    # POST mnoe/jpi/v1/admin/notifications/notified
    def notified
      if params[:object_type] == 'task'
        task = MnoEnterprise::Task.find(params[:object_id])
        return render_not_found('task') unless task
        task.notification_received(orga_relation_id, params[:notification_type])
      else
        return render_bad_request('notified', "Invalid object_type: #{params[:object_type]}")
      end
      head :ok
    end

    private

    def orga_relation_id
      @orga_relation_id ||= MnoEnterprise::OrgaRelation.where(user_id: current_user.id).first.id
    end
  end
end
