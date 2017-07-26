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
        @task.recipients.create(recipient_params)
        MnoEnterprise::EventLogger.info('task_create', current_user.id, 'Task Creation', @task)
        MnoEnterprise::SystemNotificationMailer.task_notification().deliver_now unless send_task
        render 'show'
      else
        render_bad_request('create task', @task.errors)
      end
    end

    # PATCH /mnoe/jpi/v1/admin/tasks/1
    def update
      return render_not_found('task') unless task
      if task.update(task_params)
        task.recipients.map! { |recipient| recipient.update(recipient_params) } if send_task
        render 'show'
      else
        render_bad_request('update task', task.errors)
      end
    end

    private

    def tasks
      @tasks ||= MnoEnterprise::Task
    end

    def task
      @task ||= MnoEnterprise::Task.find(params[:id].to_i)
    end
    
    def send_task
      params[:task][:status] == 'sent'
    end

    def recipient_params
      permitted_params = params.require(:task).permit(:orga_relation_id, :reminder_date, :read_at)
        .merge(task_id: @task.id)
      # Update the param notified_at when the task is sent
      permitted_params.merge!(notified_at: Time.new) if send_task
      permitted_params
    end

    def task_params
      # For an admin, the owner_id isn't important, so we pass the first one
      owner_id = current_user.organizations.first.orga_relation_id
      permitted_params = params.require(:task).permit( :title, :message, :send_at, :status, :due_date, :completed_at, :completed_notified_at, :orga_relation_id)
        .merge(owner_id: owner_id)
      permitted_params
    end
  end
end
