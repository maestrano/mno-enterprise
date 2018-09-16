require "action_controller/metal"

module Devise
  # Failure application that will be called every time :warden is thrown from
  # any strategy or hook. Responsible for redirect the user to the sign in
  # page based on current scope and mapping. If no scope is given, redirect
  # to the default_url.
  class FailureApp < ActionController::Metal

    protected

    # Monkey patching to unset opts[:script_name]
    # See https://github.com/plataformatec/devise/issues/4127
    def scope_url
      opts  = {}
      route = route(scope)
      opts[:format] = request_format unless skip_format?

      config = Rails.application.config

      # Monkey Patch
      if config.respond_to?(:relative_url_root) && config.relative_url_root.present?
        opts[:script_name] = config.relative_url_root
      end
      # EO Monkey Patch

      router_name = Devise.mappings[scope].router_name || Devise.available_router_name
      context = send(router_name)

      if context.respond_to?(route)
        context.send(route, opts)
      elsif respond_to?(:root_url)
        root_url(opts)
      else
        "/"
      end
    end
  end
end
