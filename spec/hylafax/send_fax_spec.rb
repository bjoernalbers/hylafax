require 'spec_helper'

module HylaFAX
  RSpec.describe SendFax do
    describe '#run' do
      let(:dialstring) { '0123456789' }
      let(:document) { 'spec/support/test.pdf' }
      let(:ftp) { double('ftp') }
      subject { described_class.new(
        ftp: ftp, dialstring: dialstring, document: document) }

      before do
        allow(ftp).to receive(:connect)
        allow(ftp).to receive(:login)
        allow(ftp).to receive(:sendcmd)
        allow(ftp).to receive(:put)
      end

      it 'sends fax via ftp' do
        subject.run
        expect(ftp).to have_received(:connect).with('127.0.0.1', 4559).ordered
        expect(ftp).to have_received(:login).with('anonymous', 'anonymous').
          ordered
        expect(ftp).to have_received(:put).
          with(document, 'tmp/fb2e9fe62036b19cc3488b11fd64041a').ordered
        expect(ftp).to have_received(:sendcmd).with('JNEW').ordered
        expect(ftp).to have_received(:sendcmd).with('JPARM LASTTIME 000259').
          ordered
        expect(ftp).to have_received(:sendcmd).
          with("JPARM DIALSTRING \"#{dialstring}\"").ordered
        expect(ftp).to have_received(:sendcmd).
          with("JPARM DOCUMENT \"tmp/fb2e9fe62036b19cc3488b11fd64041a\"").ordered
        expect(ftp).to have_received(:sendcmd).with('JSUBM').ordered
      end
    end
  end
end
