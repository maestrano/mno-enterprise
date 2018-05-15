# frozen_string_literal: true

module MnoEnterprise
  module PlatformAdapters
    # Nex!™ Adapter for MnoEnterprise::PlatformClient when app has more than one node
    # The Nex!™ docker image provide `awscli` and a Minio storage addon
    class NexClusterAdapter < NexAdapter
      class << self
        # @see MnoEnterprise::PlatformAdapters::Adapter#restart
        def restart(timestamp = nil)
          return FileUtils.touch('tmp/restart.txt') unless timestamp

          cmd = <<~CMD.squish
            touch tmp/restart.txt &&
            timestamp=0 &&
            while [ $timestamp -ne #{timestamp} ];
            do aux=$(echo `curl -s -X GET http://localhost/mnoe/config.json`) &&
            timestamp=${aux:-0} &&
            sleep 1; done
          CMD
          c = NexClient::ExecCmd.new(
            name: "check restart timestamp",
            script: cmd,
            local: true,
            parallel: false
          )
          c.relationships.executor = nex_app
          c.save

          c.execute

          Rails.cache.write("exec_cmd_id", c.id)
        end

        def restart_status
          setup_nex_client
          # TODO: Need to adapt depending on the cache_store
          cmd_id = Rails.cache.fetch("exec_cmd_id")
          cmd = NexClient::ExecCmd.select(:status).find(cmd_id).first
          cmd.status
        end
      end
    end
  end
end
