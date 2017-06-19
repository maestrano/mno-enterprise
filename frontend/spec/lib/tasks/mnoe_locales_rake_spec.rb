require 'rails_helper'
require 'mno_enterprise/testing_support/shared_contexts/rake_task'

describe 'mnoe:locales:generate' do
  include_context 'rake_task'

  let(:generator)  { instance_double("MnoEnterprise::Frontend::LocalesGenerator", generate_json: true)}

  before do
    allow(MnoEnterprise::Frontend::LocalesGenerator).to receive(:new) { generator }
    allow(generator).to receive(:generate_json)
    allow_any_instance_of(Rake::FileUtilsExt).to receive(:cp_r)
    allow(rake['mnoe:locales:impac']).to receive(:invoke)
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

  it 'invokes the mnoe:locales:impac task' do
    expect(rake['mnoe:locales:impac']).to receive(:invoke)
    subject.invoke
  end
end


describe 'mnoe:locales:impac' do
  include_context 'rake_task'

  before do
    allow_any_instance_of(Rake::FileUtilsExt).to receive(:cp_r)
    allow(Dir).to receive(:foreach) { [] }
  end

  it 'copies the locales to the public folder' do
    expect_any_instance_of(Rake::FileUtilsExt).to receive(:cp_r).with(
      'tmp/build/frontend/bower_components/impac-angular/dist/locales/.',
      'public/dashboard/locales/impac/'
    )
    subject.invoke
  end

  it 'transform 4 letters locales to 2 letters locales' do
    allow(Dir).to receive(:foreach).and_yield('en-GB.json')
    expect(File).to receive(:rename).with(
      'public/dashboard/locales/impac/en-GB.json',
      'public/dashboard/locales/impac/en.json'
    )
    subject.invoke
  end
end
