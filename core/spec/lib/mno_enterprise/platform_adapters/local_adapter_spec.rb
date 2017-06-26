# frozen_string_literal: true
require "rails_helper"

describe MnoEnterprise::PlatformAdapters::LocalAdapter do
  # TODO: shared example? "it_behave_likes MnoEnterprise::PlatformAdapters::Adapter"
  it { expect(described_class).to respond_to(:restart) }

  describe '.restart' do
    it 'touches the restart file' do
      expect(FileUtils).to receive(:touch).with('tmp/restart.txt')
      described_class.restart
    end
  end
end

