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

    def create_build(app, commit, cid)
      data = { "cid" => cid, "build" => { "commit" => commit } }
      res = Connection.new.request(:post, "/apps/#{app['id']}/builds", data)
      return nil unless res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    end

    def fail_build(app)
      # return if app.nil? || build.nil?
      # Connection.new.request(:put, "/apps/#{app['id']}/builds/#{build['id']}", { "build" => { "status" => STATUS_FAILED } })
    end
  end
end
