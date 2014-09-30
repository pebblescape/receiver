require 'net/http'
require 'digest/md5'
require 'base64'
require "pebble_receiver/connection"

module PebbleReceiver
  module MikeHelpers
    def validate_key(key)
      fingerprint = generate_fingerprint(key)
      res = Connection.new.request(:get, "/auth", { fingerprint: fingerprint})
      res.is_a?(Net::HTTPSuccess)
    end
    
    PUBRE = /^(ssh-[dr]s[as]\s+)|(\s+.+\@.+)|\n/
    COLONS = /(.{2})(?=.)/
    
    def generate_fingerprint(key)
      pubkey = key.clone.gsub(PUBRE, '')
      pubkey = Digest::MD5.hexdigest(Base64.decode64(pubkey))
      pubkey.gsub!(COLONS, '\1:')
    end
  end
end
