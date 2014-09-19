require "pebble_receiver/receiver"
require "pebble_receiver/auther"

module PebbleReceiver  
  class Init
    def self.start(path, commit)
      PebbleReceiver::Receiver.new(path, commit)
    end
  end
  
  class Auth
    def self.start(user, key)
      auther = PebbleReceiver::Auther.new(user, key)
      auther.auth
    end
  end
end