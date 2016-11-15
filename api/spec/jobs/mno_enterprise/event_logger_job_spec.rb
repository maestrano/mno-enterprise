require 'rails_helper'

module MnoEnterprise
  RSpec.describe EventLoggerJob, type: :job do
    it 'dispatch the notification to the event logger' do
      args = ['app_destroy', 1, 'App destroyed', 'Xero', build(:app_instance)]
      expect(EventLogger).to receive(:send_info).with(*args)
      EventLoggerJob.perform_now(:info, *args)
    end
  end
end
