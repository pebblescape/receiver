require "pebble_receiver/receiver"

module PebbleReceiver  
  class Init
    def self.start(path, commit)
      PebbleReceiver::Receiver.new(path, commit)
    end
  end
end