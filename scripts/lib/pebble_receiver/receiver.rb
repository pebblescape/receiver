require "fileutils"
require "shellwords"
require "json"
require "pebble_receiver/mike_helpers"
require "pebble_receiver/shell_helpers"

class PebbleReceiver::Receiver
  include PebbleReceiver::MikeHelpers
  include PebbleReceiver::ShellHelpers

  attr_accessor :name, :commit, :repo, :cache_path, :cid, :app, :build, :release

  def initialize(path, commit)
    @name, @commit = path, commit

    fetch_app
    setup_cache
    push
  rescue Exception => e
    error(e.message)
  end

  def fetch_app
    topic "Loading app info..."
    @app = get_app(name)
    assert(!app.nil?, "You have no app called #{name}")
  end

  def setup_cache
    @cache_path = "/tmp/pebble-cache/#{name}"
    FileUtils.mkdir_p(cache_path)
  end

  def push
    @cid = run!("docker run -i -a stdin -v #{cache_path}:/tmp/cache:rw pebbles/pebblerunner build").gsub("\n", "")
    pipe!("docker attach #{cid}", no_indent: true)

    @release = post_push(app, commit, cid)
    # @build = release['build']
    assert(release.is_a?(Hash), "Release failed: #{release}")

    topic "Release v#{release['version']} deployed"
  end

  def assert(value, message="Assertion failed")
    raise Exception, message, caller unless value
  end
end
