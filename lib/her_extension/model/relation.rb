# TODO: we should do a PR to the HER project with a feature
# to support jsonapi.org
module Her
  module Model
    class Relation

      # Override Her::Model::Relation#where
      # to follow jsonapi.org standards
      # Use filter instead of raw parameters
      def where(params = {})
        return self if unchanged_with?(:filter, params)
        self.clone.tap do |r|
          r.params[:filter] = {}
          r.params[:filter].merge!(params)
          r.clear_fetch_cache!
        end
      end
      alias all where
      
      # E.g:
      # Product.order_by('created_at.desc','name.asc')
      def order_by(*args)
        return self if unchanged_with?(:sort, args)
        self.clone.tap do |r|
          r.params[:sort] = [r.params[:sort],args].flatten.compact.uniq
          r.clear_fetch_cache!
        end
      end
      alias sort_by order_by
      
      # ActiveRecord-like order
      # Product.order("created_at DESC, name ASC")
      def order(string_query)
        args = string_query.split(',').map do |q| 
          field, direction = q.strip.split(/\s+/).compact
          [field, direction ? direction.downcase : nil].join('.')
        end
        self.order_by(*args)
      end
      alias sort order
      
      # Limit the number of results returned
      def limit(max)
        return self if unchanged_with?(:limit, max)
        self.clone.tap do |r|
          r.params[:limit] = max
          r.clear_fetch_cache!
        end
      end
      
      # Refetch the relation
      def reload
        clear_fetch_cache!
        fetch
      end
      
      private
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