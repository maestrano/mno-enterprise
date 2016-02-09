require 'rails_helper'

module MnoEnterprise
  describe Engine do
    describe 'cache configuration' do
      it 'enables ActionController caching' do
        expect(ActionController::Base.perform_caching).to be true
      end

      it 'uses ActiveSupport::Cache::MemoryStore' do
        expect(Rails.cache).to be_a(ActiveSupport::Cache::MemoryStore)
        expect(ActionController::Base.cache_store).to be_a(ActiveSupport::Cache::MemoryStore)
      end
    end
  end
end
