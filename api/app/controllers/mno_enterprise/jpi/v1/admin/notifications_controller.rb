module MnoEnterprise
  class Jpi::V1::Admin::NotificationsController < Jpi::V1::Admin::BaseResourceController

    helper_method :format_notification_sender, :format_date

    # GET mnoe/jpi/v1/admin/notifications
    def index
      @tasks_to_be_reminded = MnoEnterprise::Task.recipient(orga_relation_id).to_be_reminded
      @due_tasks = MnoEnterprise::Task.recipient(orga_relation_id).due
      @completed_tasks = MnoEnterprise::Task.owner(orga_relation_id).completed
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

    def format_notification_sender(task)
      "#{task[:owner][:user][:name]} #{task[:owner][:user][:surname]} - #{task[:owner][:organization][:name]}"
    end

    def format_date(date)
      date.today? ? 'today' : date.strftime('%a, %d %b %Y')
    end

    private

    def orga_relation_id
      @orga_relation_id ||= current_user.organizations.first.orga_relation_id
    end
  end
end
