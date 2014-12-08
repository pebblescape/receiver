require "fileutils"
require "shellwords"
require "json"
require "pebble_receiver/mike_helpers"
require "pebble_receiver/shell_helpers"

class PebbleReceiver::Receiver
  include PebbleReceiver::MikeHelpers
  include PebbleReceiver::ShellHelpers

  attr_accessor :name, :commit, :repo, :user, :cache_path, :cid, :app, :build

  def initialize(path, commit, user)
    @name, @commit, @user = path, commit, user

    fetch_app
    setup_cache
    build_image
    deploy
  rescue SystemExit
    fail_build(app)
  rescue Exception => e
    fail_build(app)
    error(e.message)
  end

  def fetch_app
    topic "Loading app info..."
    @app = get_app(name)
    assert(!app.nil?, "User #{user} has no app called #{name}")
  end

  def setup_cache
    @cache_path = "/tmp/pebble-cache/#{name}"
    FileUtils.mkdir_p(cache_path)
  end

  def build_image
    @cid = run!("docker run -i -a stdin -v #{cache_path}:/tmp/cache:rw pebbles/pebblerunner build").gsub("\n", "")
    pipe!("docker attach #{cid}", no_indent: true)

    @build = create_build(app, commit, cid)
    assert(build['status'] == 'succeeded', "Build #{build['id']} failed")

    topic "Created build #{build['id']}..."
  end

  def deploy
    topic "Deployed release..."
  end

  def assert(value, message="Assertion failed")
    raise Exception, message, caller unless value
  end
end
