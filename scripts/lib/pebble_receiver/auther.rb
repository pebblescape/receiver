require "fileutils"
require "pebble_receiver/mike_helpers"
require "pebble_receiver/shell_helpers"

class PebbleReceiver::Auther
  include PebbleReceiver::MikeHelpers
  include PebbleReceiver::ShellHelpers
  
  attr_accessor :user, :key
  
  def initialize(user, key)
    @user, @key = user, key
  end
  
  # return 0 for success, anything else for fail
  def auth
    return 0 if validate_key(key)
    return 1
  end
end