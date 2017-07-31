require 'rails_helper'
require 'mno_enterprise/testing_support/shared_contexts/rake_task'

# TODO: use fakefs rather than stub all fs calls

describe 'mnoe:locales:clean' do
  include_context 'rake_task'

  it 'deletes the locales in the temp & build folder' do
    expect(Dir).to receive(:glob).with('tmp/build/frontend/src/locales/**/*.json').and_return(['tmp/en.json'])
    expect(Dir).to receive(:glob).with('public/dashboard/locales/**/*.json').and_return(['public/en.json'])

    expect_any_instance_of(Rake::FileUtilsExt).to receive(:rm).with(['tmp/en.json'])
    expect_any_instance_of(Rake::FileUtilsExt).to receive(:rm).with(['public/en.json'])

    subject.invoke
  end
end

describe 'mnoe:locales:generate' do
  include_context 'rake_task'

  let(:generator)  { instance_double("MnoEnterprise::Frontend::LocalesGenerator", generate_json: true)}

  before do
    allow(MnoEnterprise::Frontend::LocalesGenerator).to receive(:new) { generator }
    allow(generator).to receive(:generate_json)
    allow_any_instance_of(Rake::FileUtilsExt).to receive(:cp_r)
    allow(rake['mnoe:locales:impac']).to receive(:invoke)
    allow(Dir).to receive(:glob).and_return([])
  end

  it { expect(subject.prerequisites).to include('environment') }
  it { expect(subject.prerequisites).to include('clean') }
  it { expect(subject.prerequisites).to include('impac') }

  it 'creates a generator with the correct folder' do
    subject.invoke
    expect(MnoEnterprise::Frontend::LocalesGenerator).to have_received(:new).with('tmp/build/frontend/src/locales')
  end

  it 'generates the locales' do
    subject.invoke
    expect(generator).to have_received(:generate_json)
  end

  it 'copies the locales to the public folder' do
    expect(Dir).to receive(:glob).with('tmp/build/frontend/src/locales/*.json').and_return(['locales/en.json'])
    expect_any_instance_of(Rake::FileUtilsExt).to receive(:cp).with(['locales/en.json'], 'public/dashboard/locales/')
    subject.invoke
  end
end


describe 'mnoe:locales:impac' do
  include_context 'rake_task'

  before do
    allow_any_instance_of(Rake::FileUtilsExt).to receive(:cp_r)
    allow(Dir).to receive(:foreach) { [] }
  end

  let(:impac_locales_path) { 'tmp/build/frontend/bower_components/impac-angular/dist/locales' }

  context 'when the impac locales folder does not exist' do
    before { allow(Dir).to receive(:exists?).with(impac_locales_path) { false } }

    it 'does not copy the locales' do
      expect_any_instance_of(Rake::FileUtilsExt).not_to receive(:cp_r)
      expect_any_instance_of(Rake::FileUtilsExt).not_to receive(:cp)
      subject.invoke
    end
  end

  context 'when the impac locales folder exists' do
    before { allow(Dir).to receive(:exists?).with(impac_locales_path) { true } }
    it 'copies the locales to the public folder' do
      expect_any_instance_of(Rake::FileUtilsExt).to receive(:cp_r).with(
        'tmp/build/frontend/bower_components/impac-angular/dist/locales/.',
        'tmp/build/frontend/src/locales/impac/'
      )
      subject.invoke
    end

    it 'transform 4 letters locales to 2 letters locales' do
      allow(Dir).to receive(:foreach).and_yield('en-GB.json')
      expect_any_instance_of(Rake::FileUtilsExt).to receive(:cp).with(
        'tmp/build/frontend/src/locales/impac/en-GB.json',
        'tmp/build/frontend/src/locales/impac/en.json'
      )
      subject.invoke
    end
  end
end
