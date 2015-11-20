# PR:
# fixed options loading in dynamically defined method
# changed build to not add the parent key automatically
# changed create to send raw parameters instead of doing smart stuff
module Her
  module Model
    module Associations
      class HasManyAssociation < Association

        # @private
        def self.attach(klass, name, opts)
          opts = {
            :class_name     => name.to_s.classify,
            :name           => name,
            :data_key       => name,
            :default        => Her::Collection.new,
            :path           => "/#{name}",
            :inverse_of => nil
          }.merge(opts)
          klass.associations[:has_many] << opts

          klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}
              cached_name = :"@_her_association_#{name}"
              cached_data = (instance_variable_defined?(cached_name) && instance_variable_get(cached_name))
              opts = Marshal.load(#{Marshal.dump(opts).inspect})
              cached_data || instance_variable_set(cached_name, Her::Model::Associations::HasManyAssociation.proxy(self, opts))
            end
          RUBY
        end

        # Initialize a new object with a foreign key to the parent
        #
        # @example
        #   class User
        #     include Her::Model
        #     has_many :comments
        #   end
        #
        #   class Comment
        #     include Her::Model
        #   end
        #
        #   user = User.find(1)
        #   new_comment = user.comments.build(:body => "Hello!")
        #   new_comment # => #<Comment body="Hello!">
        #
        def build(attributes = {})
          @klass.build(attributes)
        end

        # Post an object to the nested resource collection endpoint then
        # refetch the nested collection
        #
        # @example
        #   class User
        #     include Her::Model
        #     has_many :comments
        #   end
        #
        #   class Comment
        #     include Her::Model
        #   end
        #
        #   user = User.find(1)
        #   user.comments.create(:body => "Hello!")
        #   user.comments # => [#<Comment id=2 user_id=1 body="Hello!">]
        def create(attributes = {})
          resp = self.execute_request(:create,attributes)
          @klass.build(resp)
        end

        # Consider removing - not sure this method on a has_many collection has any meaning
        def update(attributes = {})
          self.execute_request(:update,attributes)
        end

        # Consider removing - not sure this method on a has_many collection has any meaning
        def destroy(attributes = {})
          self.execute_request(:destroy,attributes)
        end

        def execute_request(action, attrs)
          attributes = HashWithIndifferentAccess.new(attrs)

          # Post data to the collection endpoint
          resource = nil
          path = self.build_request_path
          method = self.method_for(action.to_sym)

          # Add ID to path if resource method
          if [:put, :patch, :delete].include?(method.to_sym)
            path += "/#{attributes[@klass.primary_key]}"
          end

          params = self.to_params(attributes).merge(:_method => method, :_path => path)
          self.request(params) do |parsed_data, response|
            resource = parsed_data if response.success?
          end

          # Reload nested collection
          self.reload if resource

          resource
        end

        # Override fetch to not do any smart stuff...
        def fetch
          super
        end

      end
    end
  end
end
