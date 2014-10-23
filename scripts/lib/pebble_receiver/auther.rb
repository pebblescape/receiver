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
  
  # return 0 for success, 1 for fail
  def auth
    return 0 if sanity_check_key(key) && validate_key(key)
    return 1
  end
  
  private
  
  def sanity_check_key(key)
    !key.empty? && key.length >= 47 && (key.start_with?('ssh-') || key[2] == ':')
  end
end