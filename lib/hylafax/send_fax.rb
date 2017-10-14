module HylaFAX
  class SendFax
    DEFAULT_HOST     = '127.0.0.1'
    DEFAULT_PORT     = 4559
    DEFAULT_USER     = 'anonymous'
    DEFAULT_PASSWORD = 'anonymous'

    attr_reader :ftp, :host, :port, :user, :password, :dialstring, :document

    def initialize(opts = {})
      @ftp        = opts.fetch(:ftp)      { Net::FTP.new }
      @host       = opts.fetch(:host)     { DEFAULT_HOST }
      @port       = opts.fetch(:port)     { DEFAULT_PORT }
      @user       = opts.fetch(:user)     { DEFAULT_USER }
      @password   = opts.fetch(:password) { DEFAULT_PASSWORD }
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
      ftp.put(document, remote_document)
    end

    def remote_document
      File.join('tmp', Digest::MD5.file(document).to_s)
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
