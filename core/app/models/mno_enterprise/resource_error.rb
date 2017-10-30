module MnoEnterprise
  class ResourceError < StandardError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end

    def message
      errors.full_messages.join(', ')
    end
  end
end
