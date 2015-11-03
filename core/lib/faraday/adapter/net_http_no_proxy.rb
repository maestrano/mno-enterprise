module Faraday
  class Adapter
    class NetHttpNoProxy < Faraday::Adapter::NetHttp
      def net_http_connection(env)
        # Monkey Patch, never use the request to set the proxy settings, let Net::HTTP figure out by itself from
        # the environment variables

        # Original code:
        # if proxy = env[:request][:proxy]
        #   Net::HTTP::Proxy(proxy[:uri].host, proxy[:uri].port, proxy[:user], proxy[:password])
        # else
        #   Net::HTTP
        # end.new(env[:url].host, env[:url].port || (env[:url].scheme == 'https' ? 443 : 80))

        Net::HTTP.new(env[:url].host, env[:url].port || (env[:url].scheme == 'https' ? 443 : 80))
      end
    end
  end
end
