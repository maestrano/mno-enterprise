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
      # For an admin, the orga_rel_id isn't important, so we pass the first one
      owner_id = current_user.organizations.first.orga_relation_id
      if @task = MnoEnterprise::Task.create(task_params.merge(owner_id: owner_id ))
        MnoEnterprise::TaskRecipient.create(task_id: @task.id,  orga_relation_id: owner_id )
        MnoEnterprise::EventLogger.info('task_create', current_user.id, 'Task Creation', @task)
        render 'show'
      else
        render_bad_request('create task', @task.errors)
      end
    end

    private

    def tasks
      @tasks ||= MnoEnterprise::Task
    end

    def task
      @task ||= MnoEnterprise::Task.find(params[:id].to_i)
    end

    def task_params
      params.require(:task).permit(:title, :message, :send_at, :status, :due_date, :completed_at, :completed_notified_at)
    end
  end
end
