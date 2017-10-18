require 'net/ftp'
require 'digest/md5'

require 'hylafax/version'
require 'hylafax/command'
require 'hylafax/send_fax'
require 'hylafax/fax_stat'

module HylaFAX
  def self.sendfax(*opts)
    SendFax.new(*opts).run
  end

  def self.faxstat(*opts)
    FaxStat.new(*opts).run
  end
end
