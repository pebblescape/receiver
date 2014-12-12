require 'net/http'
require 'digest/md5'
require 'base64'
require 'json'
require 'excon'

module PebbleReceiver
  module MikeHelpers
    def validate_key(key)
      fingerprint = generate_fingerprint(key)
      res = get("/auth", { fingerprint: fingerprint })
      return nil unless res.status == 200
      resp = JSON.parse(res.body)
      puts resp['email']
    end

    PUBRE = /^(ssh-[dr]s[as]\s+)|(\s+.+\@.+)|\n/
    COLONS = /(.{2})(?=.)/

    def generate_fingerprint(key)
      pubkey = key.clone.gsub(PUBRE, '')
      pubkey = Digest::MD5.hexdigest(Base64.decode64(pubkey))
      pubkey.gsub!(COLONS, '\1:')
    end

    def get_app(app)
      res = get("/apps/#{app}")
      return nil unless res.status == 200
      JSON.parse(res.body)
    end

    def post_push(app, commit, cid)
      data = { "cid" => cid, "build" => { "commit" => commit } }
      res = post("/apps/#{app['id']}/push", data)
      return res.body unless res.status == 200
      JSON.parse(res.body)
    end

    # HTTP methods

    def endpoint
      "http://#{ENV['MIKE_PORT_5000_TCP_ADDR']}:#{ENV['MIKE_PORT_5000_TCP_PORT']}"
    end

    def headers
      {
        'Accept'                => 'application/vnd.pebblescape+json; version=1',
        'Content-Type'          => 'application/json',
        'Accept-Encoding'       => 'gzip',
        'User-Agent'            => 'pebblescape-receiver',
        'X-Ruby-Version'        => RUBY_VERSION,
        'X-Ruby-Platform'       => RUBY_PLATFORM
      }
    end

    def auth_query(query)
      auth = {'api_key' => ENV['MIKE_AUTH_KEY']}
      auth['api_login'] = ENV['RECEIVE_AUTH'] if ENV['RECEIVE_AUTH'] # /receive script
      query.merge(auth)
    end

    def get(path, query={})
      Excon.get(endpoint, headers: headers, path: path, query: auth_query(query))
    end

    def post(path, body={})
      Excon.new(endpoint, headers: headers).request(
        method: :post,
        path: path,
        query: auth_query({}),
        body: body.to_json
      )
    end
  end
end
