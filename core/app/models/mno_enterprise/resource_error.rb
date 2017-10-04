module MnoEnterprise
  class ResourceError < StandardError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end

    def message
      errors.map { |e|
        s = StringIO.new
        s << e.source_parameter + ': ' if e.respond_to?(:source_parameter)
        s << e.title + ': ' if e.respond_to?(:title)
        s.string
      }.join(', ')
    end
  end
end
