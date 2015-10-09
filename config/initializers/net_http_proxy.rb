###
# Ruby 2.1.2 and 2.2.0 implementations do not apply the no_proxy parameter to bypass proxy for specified hosts
# This monkey patch fixes net/http to make proper use of the no_proxy directive
###

if ENV['http_proxy'] || ENV['HTTP_PROXY']

  # If you just upgraded Ruby and faced the error below, please if ruby class net/http/http.rb now supports
  # the use of no_proxy. If it doesn't and the patch below is still working for your ruby version, just add
  # your current ruby version to the array below
  if !['2.1.2','2.2.0'].include?(RUBY_VERSION)
    raise "Your Ruby version #{RUBY_VERSION} may not allow monkey patching Net::HTTP.Proxy, please check config/initializers/net_http_proxy.rb"
  end

  require 'net/http'

  module Net
    class HTTP

      # Check if proxy should be used for this address
      def no_proxy?
        name = "no_proxy"
        if no_proxy = ENV[name] || ENV[name.upcase]
          no_proxy.scan(/([^:,|]*)(?::(\d+))?/) do |h, p|
            if /(\A|\.)#{Regexp.quote(h)}\z/i =~ address &&
              (!p || port == p.to_i)
              return true
            end
          end
        end
        false
      end

      def proxy?
        !!if @proxy_from_env && !no_proxy?
        proxy_uri
        else
          @proxy_address
        end
      end
    end
  end

end
