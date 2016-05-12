require 'rails_helper'


describe MnoEnterprise::ApplicationController, type: :controller do
  describe '#add_param_to_fragment' do
    let(:controller) { described_class.new }

    it { expect(subject.send(:add_param_to_fragment, '/#/platform/accounts', 'foo', 'bar')).to eq('/#/platform/accounts?foo=bar') }
    it { expect(subject.send(:add_param_to_fragment, '/', 'foo', 'bar')).to eq('/#?foo=bar') }
    it { expect(subject.send(:add_param_to_fragment, '/#/platform/dashboard/he/43?en=690', 'foo', 'bar')).to eq('/#/platform/dashboard/he/43?en=690&foo=bar') }
    it { expect(subject.send(:add_param_to_fragment, '/#/platform/dashboard/he/43?en=690', 'foo', [{msg: 'yolo'}])).to eq('/#/platform/dashboard/he/43?en=690&foo=%7B%3Amsg%3D%3E%22yolo%22%7D') }
  end
end
