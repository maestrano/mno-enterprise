# Add reload to the list of proxy methods
module Her
  module Model
    module Associations
      class AssociationProxy < (ActiveSupport.const_defined?('ProxyObject') ? ActiveSupport::ProxyObject : ActiveSupport::BasicObject)
        
        install_proxy_methods :association,
          :build, :create, :update, :destroy, :where, :find, :all, :assign_nested_attributes, :reload
        
        
        def method_missing(name, *args, &block)
          if :object_id == name # avoid redefining object_id
            return association.fetch.object_id
          end
          
          begin
            return self.association.send(name,*args,&block)
          rescue ::NoMethodError => e
            puts e.backtrace.join("\n")          
            # create a proxy to the fetched object's method
            metaclass = (class << self; self; end)
            metaclass.install_proxy_methods 'association.fetch', name
          end

          # resend message to fetched object
          __send__(name, *args, &block)
        end
      end
    end
  end
end
