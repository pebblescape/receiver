require "fileutils"
require "pebble_receiver/shell_helpers"

class PebbleReceiver::Auther
  include PebbleReceiver::ShellHelpers
  
  attr_accessor :user, :key
  
  def initialize(user, key)
    @user, @key = user, key
  end
  
  def auth
    exit 0
  end
end