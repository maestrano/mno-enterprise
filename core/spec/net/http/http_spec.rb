require 'rails_helper'
require 'net/http'

describe Net::HTTP do
 describe '.Proxy' do

   let(:host) { 'example.com' }
   let(:http_proxy) { 'http://localhost:3128' }
   let(:proxy_host) { 'localhost' }

   subject { Net::HTTP.new(host) }

   context 'without proxy' do
     before { load 'config/initializers/net_http_proxy.rb' }

     it { expect(subject.proxy?).to be false }
   end

   context 'with environment proxy' do
     before { ENV['http_proxy'] = http_proxy }
     before { load 'config/initializers/net_http_proxy.rb' }

     it { expect(subject.proxy?).to be true }
   end

   context 'with environment proxy and no_proxy setting' do
     before { ENV['http_proxy'] = http_proxy }
     before { ENV['no_proxy'] = 'example.com' }
     before { load 'config/initializers/net_http_proxy.rb' }

     it { expect(subject.proxy?).to be false }
   end

   context 'with environment proxy and no_proxy setting several hosts' do
     before { ENV['http_proxy'] = http_proxy }
     before { ENV['no_proxy'] = 'localhost,example.com' }
     before { load 'config/initializers/net_http_proxy.rb' }

     it { expect(subject.proxy?).to be false }
   end
 end
end
