module HylaFAX
  class Command
    DEFAULT_HOST     = '127.0.0.1'
    DEFAULT_PORT     = 4559
    DEFAULT_USER     = 'anonymous'
    DEFAULT_PASSWORD = 'anonymous'

    attr_reader :ftp, :host, :port, :user, :password

    def initialize(opts = {})
      @ftp      = opts.fetch(:ftp)      { Net::FTP.new }
      @host     = opts.fetch(:host)     { DEFAULT_HOST }
      @port     = opts.fetch(:port)     { DEFAULT_PORT }
      @user     = opts.fetch(:user)     { DEFAULT_USER }
      @password = opts.fetch(:password) { DEFAULT_PASSWORD }

      @ftp.passive = true if opts[:passive]
    end

    private

    def connect
      ftp.connect(host, port)
    end

    def login
      ftp.login(user, password)
    end
  end
end
