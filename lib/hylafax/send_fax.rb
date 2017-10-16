module HylaFAX
  class SendFax
    DEFAULT_HOST     = '127.0.0.1'
    DEFAULT_PORT     = 4559
    DEFAULT_USER     = 'anonymous'
    DEFAULT_PASSWORD = 'anonymous'
    DEFAULT_TMP_DIR   = 'tmp'

    attr_reader :ftp, :host, :port, :user, :password, :dialstring, :document,
      :tmp_dir

    def initialize(opts = {})
      @ftp        = opts.fetch(:ftp)      { Net::FTP.new }
      @host       = opts.fetch(:host)     { DEFAULT_HOST }
      @port       = opts.fetch(:port)     { DEFAULT_PORT }
      @user       = opts.fetch(:user)     { DEFAULT_USER }
      @password   = opts.fetch(:password) { DEFAULT_PASSWORD }
      @tmp_dir    = opts.fetch(:tmp_dir)  { DEFAULT_TMP_DIR }
      @dialstring = opts.fetch(:dialstring)
      @document   = opts.fetch(:document)
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
    end

    private

    def connect
      ftp.connect(host, port)
    end

    def login
      ftp.login(user, password)
    end

    def upload_document
      ftp.put(document, remote_document) unless document_uploaded?
    end

    def remote_document
      File.join(tmp_dir, document_filename)
    end

    def document_filename
      Digest::MD5.file(document).hexdigest
    end

    def document_uploaded?
      ftp.list(tmp_dir).map { |l| l.split.last }.include?(document_filename)
    end

    def create_new_job
      ftp.sendcmd('JNEW')
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
