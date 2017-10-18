module HylaFAX
  class SendFax < Command
    DEFAULT_TMP_DIR = 'tmp'
    DOCUMENT_PREFIX = 'doc.'

    attr_reader :dialstring, :document, :tmp_dir, :job_id

    def initialize(opts = {})
      super
      @tmp_dir    = opts.fetch(:tmp_dir) { DEFAULT_TMP_DIR }
      @dialstring = opts.fetch(:dialstring)
      @document   = opts.fetch(:document)
      @job_id     = nil
    end

    def run
      connect
      login
      upload_document
      create_new_job
      set_lasttime
      set_dialstring
      set_document
      submit_job
      job_id
    end

    private

    def upload_document
      ftp.put(document, remote_document) unless document_uploaded?
    end

    def remote_document
      File.join(tmp_dir, document_filename)
    end

    def document_filename
      @document_filename ||= DOCUMENT_PREFIX +
        Digest::MD5.file(document).hexdigest
    end

    def document_uploaded?
      ftp.list(tmp_dir).map { |l| l.split.last }.include?(document_filename)
    end

    def create_new_job
      /jobid:\s+(\d+)\s+/ =~ ftp.sendcmd('JNEW')
      @job_id = $1.to_i if $1
    end

    def set_lasttime
      ftp.sendcmd('JPARM LASTTIME 000259')
    end

    def set_dialstring
      ftp.sendcmd("JPARM DIALSTRING \"#{dialstring}\"")
    end

    def set_document
      ftp.sendcmd("JPARM DOCUMENT \"#{remote_document}\"")
    end

    def submit_job
      ftp.sendcmd('JSUBM')
    end
  end
end
