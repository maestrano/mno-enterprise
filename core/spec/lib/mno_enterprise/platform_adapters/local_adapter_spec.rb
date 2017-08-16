# frozen_string_literal: true
require "rails_helper"

describe MnoEnterprise::PlatformAdapters::LocalAdapter do
  include MnoEnterprise::TestingSupport::SharedExamples::PlatformAdapter

  it_behaves_like MnoEnterprise::PlatformAdapters::Adapter

  describe '.restart' do
    it 'touches the restart file' do
      expect(FileUtils).to receive(:touch).with('tmp/restart.txt')
      described_class.restart
    end
  end
end

