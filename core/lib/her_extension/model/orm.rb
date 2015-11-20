# FIX: Reset params when blank_relation is called so that query statement (like where)
# automatically start fresh
# 
# FIX: scope to create real isolated scopes for each Her::Model
#
# FIX: add put method on model
module Her
  module Model
    module ORM
      
      # Send raw PUT request to model - no data encapsulation performed
      def put(attrs)
        method = :put
        self.class.request(attrs.merge(:_method => method, :_path => request_path)) do |parsed_data, response|
          return parsed_data
        end
      end
      
      module ClassMethods
        # Create a new chainable scope
        #
        # @example
        #   class User
        #     include Her::Model
        #
        #     scope :admins, lambda { where(:admin => 1) }
        #     scope :page, lambda { |page| where(:page => page) }
        #   enc
        #
        #   User.admins # Called via GET "/users?admin=1"
        #   User.page(2).all # Called via GET "/users?page=2"
        def scope(name, code)
          
          # Add the scope method to the class
          metaclass = (class << self; self end)
          metaclass.send(:define_method, name) do |*args|
            instance_exec(*args, &code)
          end
          Relation.scopes["#{self.to_s}.#{name}"] = code
          
          # Add the scope method to the Relation class
          Relation.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}(*args)
              parent_klass = @parent.instance_variable_get("@klass") || @parent.to_s
              instance_exec(*args,&self.class.scopes["\#{parent_klass}.#{name}"])
            end
          RUBY
        end
        
        private
          def blank_relation
            @blank_relation ||= Relation.new(self)
            @blank_relation.params = {}
            @blank_relation
          end
      end
    end
  end
end