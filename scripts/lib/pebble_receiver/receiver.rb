require "fileutils"
require "shellwords"
require "json"
require "pebble_receiver/mike_helpers"
require "pebble_receiver/shell_helpers"

class PebbleReceiver::Receiver
  include PebbleReceiver::MikeHelpers
  include PebbleReceiver::ShellHelpers

  attr_accessor :name, :commit, :repo, :user, :cache_path, :cid, :app, :build, :imgid

  def initialize(path, commit, user)
    @name, @commit, @user = path, commit, user

    fetch_app
    setup_cache
    build_image
    deploy
  rescue SystemExit
    fail_build(app, build)
  rescue Exception => e
    fail_build(app, build)
    error(e.message)
  end

  def fetch_app
    topic "Loading app info..."
    @app = get_app(name)
    assert(!app.nil?, "User #{user} has no app called #{name}")

    @build = create_build(app, commit)
    assert(!build.nil?, "Failed creating build")
  end

  def setup_cache
    @cache_path = "/tmp/pebble-cache/#{name}"
    FileUtils.mkdir_p(cache_path)
  end

  # TODO: offload everything after build to Mike
  def build_image
    @cid = run!("docker run -i -a stdin -v #{cache_path}:/tmp/cache:rw pebbles/pebblerunner build").gsub("\n", "")
    pipe!("docker attach #{cid}", no_indent: true)
    assert(container_success?(cid), "Build failed in container #{cid}")

    @imgid = run!("docker commit #{cid} #{imgtag}").gsub("\n", "")
    run!("docker rm #{cid}")

    info = run!("docker run --rm -i -t #{imgid} info")
    info = JSON.parse(info)

    @build = finish_build(app, build, info['buildpack_name'], info['process_types'], info['app_size'])
    assert(build['status'] == 'succeeded', "Finishing build #{build['id']} failed")
    topic "Commited build #{build['id']}..."
  end

  def deploy
    topic "Deployed release..."
  end

  def imgtag
    "pebble/#{name}:#{build['id']}"
  end

  def container_success?(cid)
    json = run("docker inspect #{cid}")
    info = JSON.parse(json)
    info[0]["State"]["ExitCode"] == 0
  end

  def assert(value, message="Assertion failed")
    raise Exception, message, caller unless value
  end
end
