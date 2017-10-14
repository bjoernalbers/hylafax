require 'net/ftp'
require 'digest/md5'

require 'hylafax/version'
require 'hylafax/send_fax'

module HylaFAX
  def self.sendfax(*opts)
    SendFax.new(*opts).run
  end
end
