# frozen_string_literal: true
describe 'AUDIT_LOG_CONFIG' do
  # Make sure that the constant is defined
  it { expect(AUDIT_LOG_CONFIG).to be_a Hash }
end
