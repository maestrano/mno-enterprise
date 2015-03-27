class Jpi::V1::Dashboard::User::TicketsController < ApplicationController

  before_filter :check_authorization
  before_filter :init_zdesk_client
  
  # GET /jpi/v1/dashboard/users/1/tickets.json
  def index
    @tickets = @zdesk_client.tickets
    @requester_id = @zdesk_client.requester_id
    @authors = @zdesk_client.authors
    render partial: 'index'
  end

  # POST /jpi/v1/dashboard/users/1/tickets
  def create
    if params[:subject] && params[:comment]
      @ticket = @zdesk_client.create_ticket(params[:subject],params[:comment])
      @authors = @zdesk_client.authors_ticket(@ticket)
      
      expire_action action: :index
      render partial: 'show'
    else
      render json: "Wrong parameters", status: :bad_request
    end
  end

  # PUT /jpi/v1/dashboard/users/1/tickets/2
  def update
    if comment = params[:comment]
      attachments = []
      if attachment = params[:attachment]
        attachments << attachment
      end
      @author_name = "#{current_user.name} #{current_user.surname}"
      @comment = @zdesk_client.create_comment(params[:id],comment,attachments)
      
      expire_action action: :index
      render partial: 'comment'
    else
      render json: "Wrong parameters", status: :bad_request
    end
  end

  private

  def check_authorization
    unless current_user
      render json: "Unauthorized", status: :unauthorized
    end
  end

  def init_zdesk_client
    @zdesk_client ||= ZendeskClient.new(current_user)
  end

end
