require 'net/http'
require 'uri'
require 'pebble_receiver/patches'

module PebbleReceiver
  class Connection
    VERB_MAP = {
      :get    => Net::HTTP::Get,
      :post   => Net::HTTP::Post,
      :put    => Net::HTTP::Put,
      :delete => Net::HTTP::Delete
    }

    attr_reader :http

    def initialize(endpoint = nil)
      endpoint ||= "http://#{ENV['MIKE_PORT_5000_TCP_ADDR']}:#{ENV['MIKE_PORT_5000_TCP_PORT']}"
      uri = URI.parse(endpoint)
      @http = Net::HTTP.new(uri.host, uri.port)
    end

    def request(method, path, params={})
      params.merge!({'api_key' => ENV['MIKE_AUTH_KEY']})
      params.merge!({'api_login' => ENV['RECEIVE_USER']}) if ENV['RECEIVE_USER'] # /receive script

      case method
      when :get
        full_path = path_with_params(path, params)
        request = VERB_MAP[method].new(full_path)
      else
        request = VERB_MAP[method].new(path)
        # request.set_form_data(params.to_http_params)
        request.body = params.to_query
        request.content_type = 'application/x-www-form-urlencoded'
      end

      request['Accept'] = "application/vnd.pebblescape+json; version=1"

      http.request(request)
    end

    private

    def path_with_params(path, params)
      encoded_params = URI.encode_www_form(params)
      [path, encoded_params].join("?")
    end
  end
end
