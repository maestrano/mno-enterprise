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
      render template: 'mno_enterprise/jpi/v1/tasks/index'
    end

    # GET /mnoe/jpi/v1/admin/tasks/1
    def show
      task
      render_not_found('task') unless @task
      render template: 'mno_enterprise/jpi/v1/tasks/show'
    end

    # POST /mnoe/jpi/v1/admin/tasks
    def create
      # For an admin, the owner_id isn't important, so we pass the first one
      owner_id = current_user.organizations.first.orga_relation_id
      if @task = MnoEnterprise::Task.create(task_params.merge(owner_id: owner_id))
        return render_bad_request('create task', @task.errors) unless @task.id
        @task.task_recipients.create(task_recipient_params)
        MnoEnterprise::EventLogger.info('task_create', current_user.id, 'Task Creation', @task)
        send_mail_notification(@task.task_recipients) if task_sent
        render template: 'mno_enterprise/jpi/v1/tasks/show'
      else
        render_bad_request('create task', @task.errors)
      end
    end

    # PATCH /mnoe/jpi/v1/admin/tasks/1
    def update
      return render_not_found('task') unless task
      if task.update(task_params)
        task.task_recipients.map! { |recipient| recipient.update(task_recipient_params) }
        render template: 'mno_enterprise/jpi/v1/tasks/show'
      else
        render_bad_request('update task', task.errors)
      end
    end

    private

    def tasks
      if params[:outbox]
        # retrieve tasks outbox
        @tasks ||= MnoEnterprise::Task.where(owner_id: current_user.organizations.first.orga_relation_id)
      else
        # retrieve tasks inbox
        @tasks ||= MnoEnterprise::Task.where('task_recipients.orga_relation_id'=> current_user.organizations.first.orga_relation_id, 'status.ne' => 'draft')
      end
    end

    def task
      @task ||= MnoEnterprise::Task.find(params[:id].to_i)
    end

    def task_sent
      params[:task][:status] == 'sent'
    end

    def task_completed
      params[:task][:status] == 'done'
    end

    def send_mail_notification(recipients)
      recipients.map { |recipient| MnoEnterprise::SystemNotificationMailer.task_notification(recipient.user, @task).deliver_later  }
    end

    def task_recipient_params
      params.require(:task).permit(:orga_relation_id, :reminder_date, :read_at).merge(task_id: @task.id)
    end

    def task_params
      permitted_params = params.require(:task).permit( :title, :message, :status, :due_date, :orga_relation_id, :send_at, :read_at)
      # Update the param send_at the day the task is sent
      permitted_params.merge!(send_at: Time.new, completed_at: nil, completed_notified_at: nil) if task_sent
      # Update the task when is completed
      permitted_params.merge!(completed_at: Time.new) if task_completed
      permitted_params
    end
  end
end
