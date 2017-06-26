require 'action_view' # To fix "uninitialized constant Haml::ActionView"
require 'jbuilder'
require 'coffee-rails'
require 'haml'
require 'credit_card_validations'

require 'mno_enterprise/core'

module MaestranoEnterprise
  module Api
    require 'mno_enterprise/api/engine'
  end
end

# Needs Rails::Engine to be loaded
require 'health_check'
