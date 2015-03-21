require 'digest/md5'

# TODO: we should do a PR to the HER project with a feature
# to support jsonapi.org
module Her
  module Model
    class Relation
      attr_accessor :cache
      
      def initialize(parent)
        @parent = parent
        @params = {}
        @cache = {}
      end
      
      # Fetch a collection of resources
      # Override to introduce cache
      # If a request is performed then the cache gets cleared, thus
      # ensuring that only identical successive requests return a
      # cached result.
      # Doing more advanced caching out of the box may lead to undesirable 
      # results and should be left to the developer.
      def fetch
        cache[query_checkum] ||= begin
          self.clear_cache!
          path = @parent.build_request_path(@params)
          method = @parent.method_for(:find)
          @parent.request(@params.merge(:_method => method, :_path => path)) do |parsed_data, response|
            @parent.new_collection(parsed_data)
          end
        end
      end
      
      # Override Her::Model::Relation#where
      # to follow jsonapi.org standards
      # Use filter instead of raw parameters
      def where(params = {})
        return self if !params || params.empty?
        self.params[:filter] = {}
        self.params[:filter].merge!(params)
        self
      end
      alias all where
      
      # E.g:
      # Product.order_by('created_at.desc','name.asc')
      def order_by(*args)
        return self if args.empty?
        self.params[:sort] = [self.params[:sort],args].flatten.compact.uniq
        self
      end
      alias sort_by order_by
      
      # ActiveRecord-like order
      # Product.order("created_at DESC, name ASC")
      def order(string_query)
        return self if !string_query || string_query.empty?
        args = string_query.split(',').map do |q| 
          field, direction = q.strip.split(/\s+/).compact
          [field, direction ? direction.downcase : nil].join('.')
        end
        self.order_by(*args)
      end
      alias sort order
      
      # Limit the number of results returned
      def limit(max = nil)
        return self if !max
        self.params[:limit] = max
        self
      end
      
      # @private
      def clear_fetch_cache!
        cache[query_checkum] = nil
      end
      
      def clear_cache!
        @cache.clear
      end
      
      def reset_params
        @params.clear
      end
      
      # Refetch the relation
      def reload
        clear_fetch_cache!
        fetch
      end
      
      private
        def query_checkum
          Digest::MD5.hexdigest(Marshal.dump(@params))
        end
        
        # Check whether the inputed params change
        # the query
        # Used to determine whether the query should
        # be changed refetched or not
        def unchanged_with?(key, params)
          case 
          when params.kind_of?(Hash)
            @params == @params.merge(key.to_sym => (@params[key] || {}).merge(params))
          when params.kind_of?(Array)
            @params == @params.merge(key.to_sym => [(@params[key] || []),params].flatten.compact.uniq)
          else
            @params == @params.merge(key.to_sym => params)
          end
        end
    end
  end
end