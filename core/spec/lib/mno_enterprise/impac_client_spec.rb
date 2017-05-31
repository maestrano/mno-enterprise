require "rails_helper"

describe MnoEnterprise::ImpacClient do
  subject { MnoEnterprise::ImpacClient }

  let(:host_path) { "https://api-impac.maestrano.test" }
  let(:params) { { sso_session: '1234' } }
  let(:endpoint) { "/some/endpoint" }
  let(:url) { "https://api-impac.maestrano.test/some/endpoint?sso_session=1234" }

  describe ".host" do
    it { expect(subject.host).to eq(host_path) }
  end

  describe ".endpoint_url" do
    it { expect(subject.endpoint_url(endpoint, params)).to eq(url) }
    context "when the endpoint misses the first '/'" do
      let(:endpoint) { "some/endpoint" }
      it { expect(subject.endpoint_url(endpoint, params)).to eq(url) }
    end
  end

  describe ".send_get" do
    let(:opts) { {some: 'opts'} }

    before { allow(subject).to receive(:get).with(url, opts).and_return(true) }

    it { expect(subject.send_get(endpoint, params, opts)).to eq(true) }
  end

end
