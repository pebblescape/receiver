require 'net/http'
require 'uri'

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
      
      case method
      when :get
        full_path = path_with_params(path, params)
        request = VERB_MAP[method].new(full_path)
      else
        request = VERB_MAP[method].new(path)
        request.set_form_data(params)
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