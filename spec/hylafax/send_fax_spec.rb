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
        %i{
          connect
          login
          upload_document
          create_new_job
          set_lasttime
          set_dialstring
          set_pagewidth
          set_pagelength
          set_document
          submit_job
        }.each do |cmd|
          allow(subject).to receive(cmd)
        end
      end

      it 'executes ftp commands in the right order' do
        subject.run
        expect(subject).to have_received(:connect).ordered
        expect(subject).to have_received(:login).ordered
        expect(subject).to have_received(:upload_document).ordered
        expect(subject).to have_received(:create_new_job).ordered
        expect(subject).to have_received(:set_lasttime).ordered
        expect(subject).to have_received(:set_dialstring).ordered
        expect(subject).to have_received(:set_pagewidth).ordered
        expect(subject).to have_received(:set_pagelength).ordered
        expect(subject).to have_received(:set_document).ordered
        expect(subject).to have_received(:submit_job).ordered
      end

      it 'returns job id' do
        allow(subject).to receive(:job_id) { 42 }
        expect(subject.run).to eq 42
      end
    end

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

    describe '#set_lasttime' do
      it 'sets lasttime by default to 3 hours' do
        allow(ftp).to receive(:sendcmd)
        subject.send(:set_lasttime)
        expect(ftp).to have_received(:sendcmd).with('JPARM LASTTIME 000259')
      end
    end

    describe '#set_dialstring' do
      it 'sets the dialstring' do
        allow(ftp).to receive(:sendcmd)
        subject.send(:set_dialstring)
        expect(ftp).to have_received(:sendcmd).
          with("JPARM DIALSTRING \"#{dialstring}\"")
      end
    end

    describe '#set_pagewidth' do
      before do
        allow(ftp).to receive(:sendcmd)
      end

      it 'sets default pagewidth' do
        subject.send(:set_pagewidth)
        expect(ftp).to have_received(:sendcmd).with('JPARM PAGEWIDTH 209')
      end

      context 'with custom pagewidth' do
        subject { described_class.new(
          ftp: ftp,dialstring: dialstring, document: document,
          pagewidth: 216) }

        it 'sets custom pagewidth' do
          subject.send(:set_pagewidth)
          expect(ftp).to have_received(:sendcmd).with('JPARM PAGEWIDTH 216')
        end
      end
    end

    describe '#set_pagelength' do
      before do
        allow(ftp).to receive(:sendcmd)
      end

      it 'sets default pagelength' do
        subject.send(:set_pagelength)
        expect(ftp).to have_received(:sendcmd).with('JPARM PAGELENGTH 296')
      end

      context 'with custom pagelength' do
        subject { described_class.new(
          ftp: ftp,dialstring: dialstring, document: document,
          pagelength: 279) }

        it 'sets custom pagelength' do
          subject.send(:set_pagelength)
          expect(ftp).to have_received(:sendcmd).with('JPARM PAGELENGTH 279')
        end
      end
    end

    describe '#set_document' do
      it 'sets the document' do
        allow(ftp).to receive(:sendcmd)
        allow(subject).to receive(:remote_document) { 'tmp/doc.deadbeef' }
        subject.send(:set_document)
        expect(ftp).to have_received(:sendcmd).
          with("JPARM DOCUMENT \"tmp/doc.deadbeef\"")
      end
    end

    describe '#submit_job' do
      it 'submits the job' do
        allow(ftp).to receive(:sendcmd)
        subject.send(:submit_job)
        expect(ftp).to have_received(:sendcmd).with('JSUBM')
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

    describe '#document_filename' do
      it 'joins document prefix with hexdigest' do
        expect(subject.send(:document_filename)).
          to eq('doc.fb2e9fe62036b19cc3488b11fd64041a')
      end
    end

    describe '#create_new_job' do
      before do
        allow(ftp).to receive(:sendcmd) {
          "200 New job created: jobid: 23 groupid: 5.\n"
        }
      end

      it 'sends "JNEW" command' do
        subject.send(:create_new_job)
        expect(ftp).to have_received(:sendcmd).with('JNEW')
      end

      it 'saves job id' do
        expect(subject.job_id).to be nil
        subject.send(:create_new_job)
        expect(subject.job_id).to eq 23
      end
    end
  end
end
