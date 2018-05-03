# frozen_string_literal: true
require "rails_helper"

describe MnoEnterprise::PlatformAdapters::NexClusterAdapter do
  include MnoEnterprise::TestingSupport::SharedExamples::PlatformAdapter

  it_behaves_like MnoEnterprise::PlatformAdapters::Adapter

  describe '.restart' do
    subject { described_class.restart(Time.current.to_i) }
    let(:exec_cmd) { NexClient::ExecCmd.new(id: 1) }
    before { allow(NexClient::ExecCmd).to receive(:new).and_return(exec_cmd) }
    before { allow(exec_cmd).to receive_messages(:save => exec_cmd, :execute => true) }

    xit 'creates a script to check to restart status' do
      expect(exec_cmd).to receive(:execute)
      subject
    end
  end
end
