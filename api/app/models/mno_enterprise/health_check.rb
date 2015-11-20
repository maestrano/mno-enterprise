module MnoEnterprise
  class HealthCheck
    # Check API connection with Mno-Hub
    # any code that returns blank on success and non blank string upon failure
    def self.perform_mno_hub_check
      # TODO: less expensive test
      if MnoEnterprise::App.first
        ''
      else
        'MNO-HUB'
      end
    rescue => e
      "MNO-HUB: #{e}. "
    end
  end
end
