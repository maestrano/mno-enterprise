module Her
  module Middleware
    # This middleware expects the resource/collection data to be contained in the `data`
    # key of the JSON object
    class MnoeApiV1ParseJson < ParseJSON
      # Parse the response body
      #
      # @param [String] body The response body
      # @return [Mixed] the parsed response
      # @private
      def parse(body)
        json = parse_json(body)
        puts json
        parse_types({
          :data => json[:data] || {},
          :errors => json[:errors] || {},
          :metadata => json[:metadata] || {}
        })
      end
      
      def parse_types(res)
        case
        when res.kind_of?(Array)
          return res.map { |e| parse_types(e) }
        when res.kind_of?(Hash)
          hash = res.dup
          hash.each do |k,v|
            hash[k] = parse_types(v)
          end
          return hash
        when res.is_a?(String) && res =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/i
          return Time.iso8601(res)
        else
          return res
        end
      end

      # This method is triggered when the response has been received. It modifies
      # the value of `env[:body]`.
      #
      # @param [Hash] env The response environment
      # @private
      def on_complete(env)
        env[:body] = case env[:status]
        when 204
          parse('{}')
        else
          parse(env[:body])
        end
      end
    end
  end
end
