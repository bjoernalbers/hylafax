require 'spec_helper'

RSpec.describe HylaFAX do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  describe '.senfax' do
    it 'creates SendFax object' do
    end
  end
end
