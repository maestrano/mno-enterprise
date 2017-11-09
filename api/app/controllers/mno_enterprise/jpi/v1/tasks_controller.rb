module MnoEnterprise
  class Jpi::V1::TasksController < Jpi::V1::BaseResourceController

    #==================================================================
    # Instance methods
    #==================================================================
    # GET /mnoe/jpi/v1/organizations/:organization/tasks
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

    # GET /mnoe/jpi/v1/organizations/:organization/tasks/1
    def show
      task
      render_not_found('task') unless @task
    end

    # POST /mnoe/jpi/v1/organizations/:organization/tasks
    def create
      owner_id = MnoEnterprise::OrgaRelation.where(user_id: current_user.id, organization_id: parent_organization.id).first.id
      if @task = MnoEnterprise::Task.create(task_params.merge!(owner_id: owner_id))
        return render_bad_request('create task', @task.errors) unless @task.id
        @task.task_recipients.create(task_recipient_params)
        MnoEnterprise::EventLogger.info('task_create', current_user.id, 'Task Creation', @task)
        send_mail_notification(@task.task_recipients) if task_sent
        render 'show'
      else
        render_bad_request('create task', @task.errors)
      end
    end

    # PATCH /mnoe/jpi/v1/organizations/:organization/tasks/1
    def update
      return render_not_found('task') unless task
      if task.update(task_params)
        task.task_recipients.map! { |recipient| recipient.update(task_recipient_params) }
        render 'show'
      else
        render_bad_request('update task', task.errors)
      end
    end

    private

    def tasks
      if params[:outbox]
        # retrieve tasks outbox, tasks where I am the owner
        orga_relation_id = MnoEnterprise::OrgaRelation.where(user_id: current_user.id, organization_id: parent_organization.id).first.id
        @task ||= MnoEnterprise::Task.where(owner_id: orga_relation_id)
      else
        # retrieve tasks inbox, tasks where I am the recipient
        orga_relation_id = MnoEnterprise::OrgaRelation.where(user_id: current_user.id, organization_id: parent_organization.id).first.id
        @tasks ||= MnoEnterprise::Task.where('task_recipients.orga_relation_id'=> orga_relation_id, 'status.ne' => 'draft')
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
      inbox_link =  "#{Rails.application.config.action_mailer.asset_host}/admin/#!/messages"
      recipients.map { |recipient| MnoEnterprise::SystemNotificationMailer.task_notification(current_user, recipient.user, @task, inbox_link, parent_organization.name).deliver_later  }
    end

    def task_recipient_params
      permitted_params = params.require(:task).permit(:orga_relation_id, :reminder_date, :read_at)
        .merge(task_id: @task.id)
      permitted_params
    end

    def task_params
      permitted_params = params.require(:task).permit(:owner_id, :title, :message, :status, :due_date, :sent_at, :read_at)
      # Update the param send_at the day the task is sent
      permitted_params.merge!(send_at: Time.new, completed_at: nil, completed_notified_at: nil) if task_sent
      # Update the task when is completed
      permitted_params.merge!(completed_at: Time.new) if task_completed
      permitted_params
    end
  end
end
