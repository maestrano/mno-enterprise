module MnoEnterprise
  class Jpi::V1::Admin::TasksController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/tasks
    def index
      if params[:terms]
        # For search mode
        @tasks = []
        JSON.parse(params[:terms]).map { |t| @tasks = @tasks | tasks.where(Hash[*t]) }
        response.headers['X-Total-Count'] = @tasks.count
      else
        @tasks = tasks
        @tasks = @tasks.limit(params[:limit]) if params[:limit]
        @tasks = @tasks.skip(params[:offset]) if params[:offset]
        @tasks = @tasks.order_by(params[:order_by]) if params[:order_by]
        @tasks = @tasks.where(params[:where]) if params[:where]
        @tasks = @tasks.all.fetch
        response.headers['X-Total-Count'] = @tasks.metadata[:pagination][:count]
      end
    end

    # GET /mnoe/jpi/v1/admin/tasks/1
    def show
      task
      render_not_found('task') unless @task
    end

    # POST /mnoe/jpi/v1/admin/tasks
    def create
      if @task = MnoEnterprise::Task.create(task_params)
        @task.task_recipients.create(task_recipient_params)
        MnoEnterprise::EventLogger.info('task_create', current_user.id, 'Task Creation', @task)
        send_mail_notification(@task.task_recipients) if send_task
        render 'show'
      else
        render_bad_request('create task', @task.errors)
      end
    end

    # PATCH /mnoe/jpi/v1/admin/tasks/1
    def update
      return render_not_found('task') unless task
      if task.update(task_params)
        task.task_recipients.map! { |recipient| recipient.update(task_recipient_params) } if send_task
        render 'show'
      else
        render_bad_request('update task', task.errors)
      end
    end

    private

    def tasks
      if params[:inbox] == 'true'
        # retrieve tasks inbox
        orga_relation_id = MnoEnterprise::OrgaRelation.where(user_id: current_user.id, organization_id: params[:organization_id]).first.id
        @tasks ||= MnoEnterprise::Task.where('task_recipients.orga_relation_id'=> orga_relation_id)
      else
        # retrieve tasks outbox
        orga_relation_id = MnoEnterprise::OrgaRelation.where(user_id: current_user.id, organization_id: params[:organization_id]).first.id
        @task ||= MnoEnterprise::Task.where(owner_id: orga_relation_id)
      end
    end

    def task
      @task ||= MnoEnterprise::Task.find(params[:id].to_i)
    end
    
    def send_task
      params[:task][:status] == 'sent'
    end

    def task_completed
      params[:task][:status] == 'done'
    end
    
    def send_mail_notification(recipients)
      recipients.map { |recipient| MnoEnterprise::SystemNotificationMailer.task_notification(recipient.user).deliver_now  }
    end

    def task_recipient_params
      permitted_params = params.require(:task).permit(:orga_relation_id, :reminder_date, :read_at)
        .merge(task_id: @task.id)
      # Update the param notified_at when the task is sent
      permitted_params.merge!(notified_at: Time.new) if send_task
      permitted_params
    end

    def task_params
      # For an admin, the owner_id isn't important, so we pass the first one
      owner_id = current_user.organizations.first.orga_relation_id
      permitted_params = params.require(:task).permit( :title, :message, :status, :due_date, :orga_relation_id, :send_at)
        .merge(owner_id: owner_id)
      # Update the param send_at the day the task is sent
      permitted_params.merge!(send_at: Time.new) if send_task
      # Update the task when is completed
      permitted_params.merge!(completed_at: Time.new) if task_completed
      permitted_params.merge!(completed_notified_at: Time.new) if task_completed
      permitted_params
    end
  end
end
