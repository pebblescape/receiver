$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'scripts', 'lib'))

require 'simplecov'
require 'simplecov-rcov'

class SimpleCov::Formatter::MergedFormatter
  def format(result)
    SimpleCov::Formatter::HTMLFormatter.new.format(result)
    SimpleCov::Formatter::RcovFormatter.new.format(result)
  end
end

SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
SimpleCov.start do
  add_group 'Library', 'lib'
end

require 'rspec'
require 'simplecov'
require 'pry'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

ENV['MIKE_PORT_5000_TCP_ADDR'] = 'localhost'
ENV['MIKE_PORT_5000_TCP_PORT'] = '5000'
ENV['MIKE_AUTH_KEY'] = '3cf455afbc3bb3b90e39453e0fbfd913b58e2de8ed48830fe7cd06c59a4fdc8f'
require 'pebble_receiver'

RSpec.configure do |config|
  config.mock_with :rspec
  config.color = true
  config.tty = true
end