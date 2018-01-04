module MnoEnterprise
  class Review < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time
    property :user_id, type: :string

    # Since Review is the parent metaclass for Comment, Feedback, Question & Answer,
    # we need to send the request to the appropriate endpoint
    def self.path(params = nil)
      @type_param = params[:type] if params
      res = super
      @type_param = nil
      res
    end

    def self.resource_path
      @type_param || super
    end
  end
end
