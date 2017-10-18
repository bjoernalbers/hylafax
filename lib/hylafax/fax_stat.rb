module HylaFAX
  class FaxStat < Command
    DEFAULT_QUEUE = 'doneq'
    JOB_FORMAT    = '%j %a'
    STATES        = {
      '?' => :undefined,
      'T' => :suspended,
      'P' => :pending,
      'S' => :sleeping,
      'B' => :blocked,
      'W' => :waiting,
      'R' => :running,
      'D' => :done,
      'F' => :failed,
    }

    attr_reader :queue

    def initialize(opts = {})
      super
      @queue = opts.fetch(:queue) { DEFAULT_QUEUE }
    end

    def run
      connect
      login
      set_jobformat
      list
    end

    private

    def set_jobformat
      ftp.sendcmd(%Q{JOBFMT "#{JOB_FORMAT}"})
    end

    def list
      ftp.list(queue).inject({ }) do |jobs, line|
        job_id, status = line.split(' ')
        jobs[job_id.to_i] = STATES[status]
        jobs
      end
    end
  end
end
