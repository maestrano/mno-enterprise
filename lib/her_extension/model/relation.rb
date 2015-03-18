# TODO: we should do a PR to the HER project with a feature
# to support jsonapi.org
module Her
  module Model
    class Relation

      # Override Her::Model::Relation#where
      # to follow jsonapi.org standards
      # Use filter instead of raw parameters
      def where(params = {})
        return self if params.blank? && !@_fetch.nil?
        self.clone.tap do |r|
          r.params[:filter] ||= {}
          r.params[:filter].merge!(params)
          r.clear_fetch_cache!
        end
      end

      # Limit the number of results returned
      def limit(max)
        return self if @_curr_limit && @_curr_limit > max && !@_fetch.nil?
        self.clone.tap do |r|
          r.params[:limit] = max
          r.clear_fetch_cache!
          r.instance_variable_set("@_curr_limit",max)
        end
      end

    end
  end
end