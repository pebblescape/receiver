require 'spec_helper'

describe PebbleReceiver::ShellHelpers do
  let(:helper_class) { Class.new { include PebbleReceiver::ShellHelpers } }
  
  it "formats ugly keys correctly" do
    env      = {%Q{ un"matched } => "bad key"}
    result   = helper_class.new.command_options_to_string("bundle install", env:  env)
    expected = %r{env \\ un\\\"matched\\ =bad\\ key bash -c bundle\\ install 2>&1}
    expect(result.strip).to match(expected)
  end

  it "formats ugly values correctly" do
    env      = {"BAD VALUE"      => %Q{ )(*&^%$#'$'\n''@!~\'\ }}
    result   = helper_class.new.command_options_to_string("bundle install", env:  env)
    expected = %r{env BAD\\ VALUE=\\ \\\)\\\(\\\*\\&\\\^\\%\\\$\\#\\'\\\$\\''\n'\\'\\'@\\!\\~\\'\\  bash -c bundle\\ install 2>&1}
    expect(result.strip).to match(expected)
  end
  
  it "sets up custom env vars" do
    helper = helper_class.new
    PebbleReceiver::ShellHelpers.user_env_hash.merge!('testkey' => 'testresult')
    expect(helper.env('testkey')).to eq('testresult')
    expect(helper.run!('env', user_env: true)).to match(/testresult/m)
  end
end