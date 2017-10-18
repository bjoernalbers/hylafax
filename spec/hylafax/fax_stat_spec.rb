require 'spec_helper'

module HylaFAX
  RSpec.describe FaxStat do
    let(:ftp) { double('ftp') }
    subject { described_class.new(ftp: ftp) }

    describe '#run' do
      before do
        %i{
          connect
          login
          set_jobformat
          list
        }.each do |cmd|
          allow(subject).to receive(cmd)
        end
      end

      it 'executes ftp command in the right order' do
        subject.run
        expect(subject).to have_received(:connect)
        expect(subject).to have_received(:login)
        expect(subject).to have_received(:set_jobformat)
        expect(subject).to have_received(:list)
      end
    end

    describe '#set_jobformat' do
      it 'sets the job format' do
        allow(ftp).to receive(:sendcmd)
        subject.send(:set_jobformat)
        expect(ftp).to have_received(:sendcmd).with('JOBFMT "%j %a"')
      end
    end

    describe '#list' do
      it 'lists the queue' do
        allow(ftp).to receive(:list) { [ ] }
        allow(subject).to receive(:queue) { 'chunky bacon' }
        subject.send(:list)
        expect(ftp).to have_received(:list).with('chunky bacon')
      end

      it 'converts list output into hash' do
        allow(ftp).to receive(:list) {
          ['1 ?', '2 T', '3 P', '4 S', '5 B', '6 W', '7 R', '8 D', '9 F' ]
        }
        expect(subject.send(:list)).to eq({
          1 => :undefined,
          2 => :suspended,
          3 => :pending,
          4 => :sleeping,
          5 => :blocked,
          6 => :waiting,
          7 => :running,
          8 => :done,
          9 => :failed
        })
      end
    end

    describe '#queue' do
      it 'returns "doneq" by default' do
        expect(subject.queue).to eq 'doneq'
      end

      it 'can be changed' do
        subject = described_class.new(ftp: ftp, queue: 'sendq')
        expect(subject.queue).to eq 'sendq'
      end
    end
  end
end
