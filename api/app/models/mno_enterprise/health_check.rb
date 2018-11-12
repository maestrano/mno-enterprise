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

    # Check that the platform is behaving as expected
    # This leverage the platform adapter self check
    def self.perform_platform_check
      SystemManager.health_check
    rescue => e
      "['platform adapter' - #{e.message}] "
    end
  end
end
