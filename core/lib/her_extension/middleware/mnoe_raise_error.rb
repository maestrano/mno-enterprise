module Her
  module Middleware
    # This middleware will raise errors based on the response status
    # Same as Faraday::Response::RaiseError, except it will catch specific
    # errors codes rather than everything in 400..600
    class MnoeRaiseError < Faraday::Response::RaiseError
      def on_complete(env)
        case env[:status]
        when 407
          # mimic the behavior that we get with proxy requests with HTTPS
          raise Faraday::Error::ConnectionFailed,
                %(407 "Proxy Authentication Required ")
        when 502..504
          raise Faraday::Error::ConnectionFailed, response_values(env)
        when 401, 500
          raise Faraday::Error::ClientError, response_values(env)
        end
      end
    end
  end
end
