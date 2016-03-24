require 'rails_helper'
require 'mno_enterprise/testing_support/shared_contexts/rake_task'

describe 'mnoe:locales:generate' do
  include_context 'rake_task'

  let(:generator)  { instance_double("MnoEnterprise::Frontend::LocalesGenerator", generate_json: true)}

  before do
    allow(MnoEnterprise::Frontend::LocalesGenerator).to receive(:new) { generator }
    allow(generator).to receive(:generate_json)
  end

  it { expect(subject.prerequisites).to include('environment') }

  it 'creates a generator with the correct folder' do
    subject.invoke
    expect(MnoEnterprise::Frontend::LocalesGenerator).to have_received(:new).with('public/dashboard/locales')
  end

  it 'generates the locales' do
    subject.invoke
    expect(generator).to have_received(:generate_json)
  end
end
