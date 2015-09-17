require 'action_view' # To fix "uninitialized constant Haml::ActionView"
require 'jbuilder'
require 'haml'

require 'mno_enterprise/core'

module MaestranoEnterprise
  module Api
    require 'mno_enterprise/api/engine'
  end
end

