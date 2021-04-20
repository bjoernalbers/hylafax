require 'spec_helper'

module HylaFAX
  RSpec.describe Command do
    let(:ftp) { double('ftp') }

    describe '#new' do
      context 'with defaults' do
        subject { described_class.new }

        it 'does not enable passive mode' do
          expect(subject.ftp.passive).to eq(false)
        end
      end

      context 'with `passive: true`' do
        subject { described_class.new(passive: true) }

        it 'enables passive mode' do
          expect(subject.ftp.passive).to eq(true)
        end
      end
    end

    describe '#connect' do
      subject { described_class.new(ftp: ftp) }

      it 'connects by default to localhost' do
        allow(ftp).to receive(:connect)
        subject.send(:connect)
        expect(ftp).to have_received(:connect).with('127.0.0.1', 4559)
      end
    end

    describe '#login' do
      subject { described_class.new(ftp: ftp) }

      it 'logs in by default as anonymous' do
        allow(ftp).to receive(:login)
        subject.send(:login)
        expect(ftp).to have_received(:login).with('anonymous', 'anonymous')
      end
    end
  end
end
