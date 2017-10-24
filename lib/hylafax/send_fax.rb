module HylaFAX
  class SendFax < Command
    DEFAULT_TMP_DIR = 'tmp'
    DEFAULT_PAGEWIDTH = 209
    DEFAULT_PAGELENGTH = 296
    DEFAULT_PAGECHOP = 'NONE'
    DEFAULT_CHOPTHRESHOLD = 0
    DOCUMENT_PREFIX = 'doc.'

    attr_reader :dialstring, :document, :tmp_dir, :job_id, :pagewidth,
      :pagelength

    def initialize(opts = {})
      super
      @tmp_dir    = opts.fetch(:tmp_dir) { DEFAULT_TMP_DIR }
      @dialstring = opts.fetch(:dialstring)
      @document   = opts.fetch(:document)
      @pagewidth  = opts.fetch(:pagewidth) { DEFAULT_PAGEWIDTH }
      @pagelength  = opts.fetch(:pagelength) { DEFAULT_PAGELENGTH }
      @job_id     = nil
    end

    def run
      connect
      login
      upload_document
      create_new_job
      set_lasttime
      set_dialstring
      set_pagewidth
      set_pagelength
      set_pagechop
      set_chopthreshold
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

    def set_pagewidth
      ftp.sendcmd(%Q{JPARM PAGEWIDTH #{pagewidth}})
    end

    def set_pagelength
      ftp.sendcmd(%Q{JPARM PAGELENGTH #{pagelength}})
    end

    def set_pagechop
      ftp.sendcmd(%Q{JPARM PAGECHOP "#{DEFAULT_PAGECHOP}"})
    end

    def set_chopthreshold
      ftp.sendcmd(%Q{JPARM CHOPTHRESHOLD #{DEFAULT_CHOPTHRESHOLD}})
    end

    def set_document
      ftp.sendcmd("JPARM DOCUMENT \"#{remote_document}\"")
    end

    def submit_job
      ftp.sendcmd('JSUBM')
    end
  end
end
