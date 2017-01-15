require 'rails_helper'
require 'mno_enterprise/testing_support/shared_contexts/rake_task'

describe 'mnoe:locales:generate' do
  include_context 'rake_task'

  let(:generator)  { instance_double("MnoEnterprise::Frontend::LocalesGenerator", generate_json: true)}

  before do
    allow(MnoEnterprise::Frontend::LocalesGenerator).to receive(:new) { generator }
    allow(generator).to receive(:generate_json)
    allow_any_instance_of(Rake::FileUtilsExt).to receive(:cp_r)
  end

  it { expect(subject.prerequisites).to include('environment') }

  it 'creates a generator with the correct folder' do
    subject.invoke
    expect(MnoEnterprise::Frontend::LocalesGenerator).to have_received(:new).with('tmp/build/frontend/src/locales')
  end

  it 'generates the locales' do
    subject.invoke
    expect(generator).to have_received(:generate_json)
  end

  it 'copies the locales to the public folder' do
    expect_any_instance_of(Rake::FileUtilsExt).to receive(:cp_r).with('tmp/build/frontend/src/locales/.', 'public/dashboard/locales/')
    subject.invoke
  end
end
