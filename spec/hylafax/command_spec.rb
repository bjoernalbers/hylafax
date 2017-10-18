require 'spec_helper'

module HylaFAX
  RSpec.describe Command do
    let(:ftp) { double('ftp') }
    subject { described_class.new(ftp: ftp) }

    describe '#connect' do
      it 'connects by default to localhost' do
        allow(ftp).to receive(:connect)
        subject.send(:connect)
        expect(ftp).to have_received(:connect).with('127.0.0.1', 4559)
      end
    end

    describe '#login' do
      it 'logs in by default as anonymous' do
        allow(ftp).to receive(:login)
        subject.send(:login)
        expect(ftp).to have_received(:login).with('anonymous', 'anonymous')
      end
    end
  end
end
