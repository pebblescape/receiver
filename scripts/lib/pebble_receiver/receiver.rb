require "fileutils"
require "pebble_receiver/shell_helpers"

class PebbleReceiver::Receiver
  include PebbleReceiver::ShellHelpers
  
  attr_accessor :app, :commit, :cache_path, :container_id
  
  def initialize(path, commit)
    @app, @commit = path, commit
    
    create_release
    setup_cache
    build_image
    deploy
  end
  
  def create_release
    topic "Creating release..."
  end
  
  def setup_cache
    @cache_path = "/tmp/pebble-cache/#{app}"
    FileUtils.mkdir_p(cache_path)
  end
  
  def build_image
    @container_id = run!("docker run -i -a stdin -v #{cache_path}:/tmp/cache:rw pebbles/pebblerunner build")
    pipe!("docker attach #{container_id}", no_indent: true)
  end  
  
  def deploy
    topic "Deploying..."
  end
end