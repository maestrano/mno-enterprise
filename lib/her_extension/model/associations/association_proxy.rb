# Add reload to the list of proxy methods
module Her
  module Model
    module Associations
      class AssociationProxy < (ActiveSupport.const_defined?('ProxyObject') ? ActiveSupport::ProxyObject : ActiveSupport::BasicObject)
        
        install_proxy_methods :association,
          :build, :create, :update, :destroy, :where, :find, :all, :assign_nested_attributes, :reload

      end
    end
  end
end
