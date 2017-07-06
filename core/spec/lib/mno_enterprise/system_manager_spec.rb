require "rails_helper"

describe MnoEnterprise::SystemManager do
  subject { described_class }

  it { is_expected.to delegate_method(:restart).to(:adapter) }
  it { is_expected.to delegate_method(:fetch_assets).to(:adapter) }
  it { is_expected.to delegate_method(:publish_assets).to(:adapter) }
  it { is_expected.to delegate_method(:update_domain).to(:adapter) }
  it { is_expected.to delegate_method(:add_ssl_certs).to(:adapter) }
end
