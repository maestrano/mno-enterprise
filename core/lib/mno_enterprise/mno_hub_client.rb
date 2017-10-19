module MnoEnterprise
  class MnoHubClient
    include HTTParty
    base_uri URI.join(MnoEnterprise.api_host, MnoEnterprise.mno_api_v2_root_path).to_s
    basic_auth MnoEnterprise.tenant_id, MnoEnterprise.tenant_key
    headers 'Accept' => 'application/vnd.api+json', 'Content-Type' => 'application/vnd.api+json'

    # Debugging
    # debug_output $stdout
    logger Rails.logger
  end
end
