require 'spec_helper'

RSpec.describe HylaFAX do
  it 'has a version number' do
    expect(described_class::VERSION).to eq '0.1.0'
  end

  describe '.senfax' do
    it 'creates SendFax object' do
    end
  end
end
