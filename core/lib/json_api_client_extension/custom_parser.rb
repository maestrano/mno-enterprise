module JsonApiClientExtension
  class CustomParser < ::JsonApiClient::Parsers::Parser
    def self.parameters_from_resource(params)
      hash = super
      parse_types(hash)
    end

    def self.parse_types(res)
      case res
        when Array
          return res.map { |e| parse_types(e) }
        when Hash
          if res.key?('cents') && res.key?('currency')
            return Money.new(res['cents'], res['currency'])
          else
            hash = res.dup
            hash.each do |k, v|
              hash[k] = parse_types(v)
            end
            return hash
          end
        when String
          if res =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/i
            return Time.iso8601(res)
          end
      end
      res
    end
  end
end


