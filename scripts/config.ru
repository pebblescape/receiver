$:.unshift File.expand_path("../lib", __FILE__)

require 'grack'
require 'grack-auth'


use Grack::Auth do |username, password|
  false
end

run Grack::Server.new({
  project_root: File.realpath('/tmp/pebble-repos'),
  upload_pack:  true,
  receive_pack: true
})
