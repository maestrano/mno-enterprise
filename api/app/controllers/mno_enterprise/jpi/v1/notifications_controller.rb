module MnoEnterprise
  class Jpi::V1::NotificationsController < Jpi::V1::BaseResourceController

    def index
      return render_bad_request("could not find orga_relation for user #{current_user.id} in organization_id #{params[:organization_id]}", nil) unless orga_relation
      orga_relation_id = orga_relation.id
      @tasks_to_be_reminded = MnoEnterprise::Task.recipient(orga_relation_id).sent.to_be_reminded.order('due_date DESC')
      @due_tasks = MnoEnterprise::Task.recipient(orga_relation_id).sent.due.order('due_date DESC')
      @completed_tasks = MnoEnterprise::Task.owner(orga_relation_id).done.completed.order('due_date DESC')
    end

    def notified
      if params[:object_type] == 'task'
        task = MnoEnterprise::Task.find(params[:object_id])
        return render_not_found('task') unless task
        task.notification_received(orga_relation.id, params[:notification_type])
      else
        return render_bad_request('notified', "Invalid object_type: #{params[:object_type]}")
      end
      head :ok
    end

    private
    def orga_relation
      @orga_relation ||= MnoEnterprise::OrgaRelation.where(user_id: current_user.id, organization_id: params[:organization_id]).first
    end
  end
end
