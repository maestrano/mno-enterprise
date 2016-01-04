# query methods should delegate to Relation
module Her
  module Model
    module Associations
      class Association
        # @private
        attr_accessor :params
        delegate :all, :order_by, :sort_by, :order, :sort, :limit, :skip, :where, to: :blank_relation
        
        # Required by Relation methods
        def build_request_path(params = {})
          build_association_path lambda { "#{@parent.request_path(@params.merge(params))}#{@opts[:path]}" }
        end
        
        # Required by Relation methods
        def method_for(meth)
          @parent.class.method_for(meth)
        end
        
        # Required by Relation methods
        def request(*args,&block)
          @parent.class.request(*args,&block)
        end
        
        # Required by Relation methods
        def new_collection(parsed_data)
          Her::Model::Attributes.initialize_collection(@klass, parsed_data)
        end
        
        # Properly format the attributes to post/put 
        def to_params(attributes)
          @parent.class.to_params(attributes,attributes)
        end
        
        # Reload the association from remote service
        def reload
          @klass.get(build_request_path, @params).tap do |result|
            @parent.attributes[@name] = result
          end
        end
        
        # Reset params when directly called on association class
        # def where(*args)
        #   blank_relation.params = {}
        #   blank_relation.where(*args)
        # end
        
        def blank_relation
          @blank_relation ||= Relation.new(self)
          @blank_relation.params = {}
          @blank_relation
        end
        
        def method_missing(name, *args, &block)
          blank_relation.send(name, *args, &block)
        end

      end
    end
  end
end
