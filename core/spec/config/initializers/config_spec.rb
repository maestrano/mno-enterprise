# frozen_string_literal: true
require 'rails_helper'

describe 'Settings' do
  it 'reads config from the ENV' do
    with_modified_env(SETTINGS__MNO__HOST: 'env_var.test') do
      Settings.reload!
      expect(Settings.mno.host).to eq('env_var.test')
    end
  end
end
