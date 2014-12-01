require "fileutils"
require "pebble_receiver/mike_helpers"
require "pebble_receiver/shell_helpers"

class PebbleReceiver::Receiver
  include PebbleReceiver::MikeHelpers
  include PebbleReceiver::ShellHelpers
  
  attr_accessor :app, :commit, :repo, :user, :cache_path, :cid, :app_info
  
  # TODO: swap user check to requests with user api key
  def initialize(path, commit, user)
    @app, @commit, @repo, @user = path, commit, user
    
    fetch_app
    setup_cache
    # build_image
    # create_release
  rescue Exception => e
    error(e.message)
  end
  
  def fetch_app
    topic "Loading app info..."
    @app_info = get_app(app)
    assert(!app_info.nil?, "No app called #{app} found")
    assert(app_info['owner']['name'] == user, "User #{user} doesn't have access to app #{app}")
  end
  
  def setup_cache
    @cache_path = "/tmp/pebble-cache/#{app}"
    FileUtils.mkdir_p(cache_path)
  end
  
  def build_image
    @cid = run!("docker run -i -a stdin -v #{cache_path}:/tmp/cache:rw pebbles/pebblerunner build")
    pipe!("docker attach #{cid}", no_indent: true)
    topic "Tagged build =v=..."
  end  
  
  def create_release
    topic "Creating release..."
  end
  
  def assert(value, message="Assertion failed")
    raise Exception, message, caller unless value
  end
end