require 'rails_helper'

describe MnoEnterprise do

  describe 'configure' do
    it 'yields self' do
      MnoEnterprise.configure { |config| expect(config).to eq(MnoEnterprise) }
    end
  end

  describe 'mnoe_api_v1' do
    let(:private_host) { nil }
    subject { MnoEnterprise.mnoe_api_v1.base_uri }
    before { MnoEnterprise.configure { |c| c.mno_api_private_host = private_host } }

    describe 'without private host' do
      it { expect(subject).to eq('https://api-enterprise.maestrano.test/api/mnoe/v1') }
    end

    describe 'with private host' do
      let(:private_host) { 'https://api-hub.account.test' }
      it { expect(subject).to eq("#{private_host}/api/mnoe/v1") }
    end
  end

  describe 'jwt' do
    before { MnoEnterprise.configure { |c| c.tenant_id = "12345789"; c.tenant_key = "abcdefg"} }
    let(:secret) { "#{MnoEnterprise.tenant_id}:#{MnoEnterprise.tenant_key}" }
    let(:token) { MnoEnterprise.jwt({ user_id: 'someid' }) }
    subject { HashWithIndifferentAccess.new(JWT.decode(token, secret).first) }

    it 'generates a valid json web token' do
      expect { subject }.to_not raise_error
    end

    it 'includes the payload' do
      expect(subject[:user_id]).to eq('someid')
    end

    it 'includes an issuer property' do
      expect(subject[:iss]).to eq(MnoEnterprise.tenant_id)
    end

    it 'includes an issue_at property' do
      expect(subject[:iat]).to be > 10.seconds.ago.to_i
    end

    it 'includes a JWT ID property' do
      expect(subject[:jit]).to eq(Digest::MD5.hexdigest("#{secret}:#{subject[:iat]}"))
    end
  end

  context 'router' do
    let(:id) { "cld-1d45e6" }
    let(:root_path) { "#{MnoEnterprise.mno_api_host}#{MnoEnterprise.mno_api_root_path}" }

    describe 'launch_url' do

      let(:url) { "#{root_path}/launch/#{id}" }
      it { expect(MnoEnterprise.router.launch_url(id)).to eq(url) }
    end

    describe 'authorize_oauth_url' do
      let(:url) { "#{root_path}/oauth/#{id}/authorize" }
      it { expect(MnoEnterprise.router.authorize_oauth_url(id)).to eq(url) }
    end

    describe 'disconnect_oauth_url' do
      let(:url) { "#{root_path}/oauth/#{id}/disconnect" }
      it { expect(MnoEnterprise.router.disconnect_oauth_url(id)).to eq(url) }
    end

    describe 'sync_oauth_url' do
      let(:url) { "#{root_path}/oauth/#{id}/sync" }
      it { expect(MnoEnterprise.router.sync_oauth_url(id)).to eq(url) }
    end
  end
end
