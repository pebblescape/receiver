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
require 'pebble_receiver'

RSpec.configure do |config|
  config.mock_with :rspec
  config.color = true
  config.tty = true
end