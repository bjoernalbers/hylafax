require 'spec_helper'

module HylaFAX
  RSpec.describe SendFax do
    let(:dialstring) { '0123456789' }
    let(:document) { 'spec/support/test.pdf' }
    let(:ftp) { double('ftp') }
    subject { described_class.new(
      ftp: ftp, dialstring: dialstring, document: document) }

    describe '#run' do
      before do
        allow(ftp).to receive(:connect)
        allow(ftp).to receive(:login)
        allow(ftp).to receive(:sendcmd)
        allow(ftp).to receive(:put)
        allow(subject).to receive(:document_uploaded?) { false }
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

    describe '#upload_document' do
      before do
        allow(ftp).to receive(:put)
        allow(subject).to receive(:document) { 'test.pdf' }
        allow(subject).to receive(:remote_document) { 'tmp/deadbeef' }
      end

      context 'when not uploaded' do
        before do
          allow(subject).to receive(:document_uploaded?) { false }
        end

        it 'uploads document' do
          subject.send(:upload_document)
          expect(ftp).to have_received(:put).with('test.pdf', 'tmp/deadbeef')
        end
      end

      context 'when already uploaded' do
        before do
          allow(subject).to receive(:document_uploaded?) { true }
        end

        it 'does not upload document' do
          subject.send(:upload_document)
          expect(ftp).not_to have_received(:put)
        end
      end
    end

    describe '#document_uploaded?' do
      before do
        allow(subject).to receive(:document_filename) { 'deadbeef' }
      end

      context 'when tmp dir does not include document filename' do
        before do
          allow(ftp).to receive(:list) {
            ["-rw----   6 anonymous    15268 Oct 11 15:59 test.pdf"]
          }
        end

        it 'is false' do
          expect(subject.send(:document_uploaded?)).to eq false
        end
      end

      context 'when tmp dir includes document filename' do
        before do
          allow(ftp).to receive(:list) {
            ["-rw----   6 anonymous    15268 Oct 11 15:59 deadbeef"]
          }
        end

        it 'is true' do
          expect(subject.send(:document_uploaded?)).to eq true
        end
      end
    end
  end
end
