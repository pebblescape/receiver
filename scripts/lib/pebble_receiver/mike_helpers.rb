require 'net/http'
require 'digest/md5'
require 'base64'
require 'json'
require "pebble_receiver/connection"

module PebbleReceiver
  module MikeHelpers
    def validate_key(user, key)
      fingerprint = generate_fingerprint(key)
      res = Connection.new.request(:get, "/auth", { fingerprint: fingerprint})
      return false unless res.is_a?(Net::HTTPSuccess)
      resp = JSON.parse(res.body)
      user == resp['login']
    end

    PUBRE = /^(ssh-[dr]s[as]\s+)|(\s+.+\@.+)|\n/
    COLONS = /(.{2})(?=.)/

    STATUS_PENDING = 1
    STATUS_FAILED = 2
    STATUS_SUCCESS = 3

    def generate_fingerprint(key)
      pubkey = key.clone.gsub(PUBRE, '')
      pubkey = Digest::MD5.hexdigest(Base64.decode64(pubkey))
      pubkey.gsub!(COLONS, '\1:')
    end

    def get_app(app)
      res = Connection.new.request(:get, "/apps/#{app}")
      return nil unless res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    end

    def create_build(app, commit)
      data = { "commit" => commit, "status" => STATUS_PENDING, "process_types" => { "web" => "test" }, "size" => 0 }
      res = Connection.new.request(:post, "/apps/#{app['id']}/builds", { "build" => data })
      return nil unless res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    end

    def fail_build(app, build)
      return if app.nil? || build.nil?
      Connection.new.request(:put, "/apps/#{app['id']}/builds/#{build['id']}", { "build" => { "status" => STATUS_FAILED } })
    end

    def finish_build(app, build, description, proctypes, size)
      data = { "status" => STATUS_SUCCESS, "process_types" => proctypes, "size" => size, "buildpack_description" => description }
      res = Connection.new.request(:put, "/apps/#{app['id']}/builds/#{build['id']}", { "build" => data })
      return nil unless res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    end
  end
end
