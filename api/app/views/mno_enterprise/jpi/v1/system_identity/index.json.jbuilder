json.system_identity do
  json.extract! @system_identity, :id, :status, :name, :description, :idp_certificate, :idp_certificate_fingerprint,
                                  :mnohub_endpoint, :connec_endpoint, :impac_endpoint, :nex_endpoint, :preferred_locale
end
