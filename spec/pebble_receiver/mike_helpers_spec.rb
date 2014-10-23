require 'spec_helper'

describe PebbleReceiver::MikeHelpers do
  let(:key) { 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3pm2f5Cd/ryLof5xIrcWkaO5rDVwix5wKd39WWF2tI8CGP/Qp9hwbYJ3puH1MKu+8MZ8vKAMtlpo+eva93Z2Qt9WR2goPah45p4TDXeuCuvfAUzbLjluhVwTdR1Moj9npoE8IetF24MkGGUPy3KlZpYd0JBxJqyLBW5Odv2eGXglOxBigwzC2JlQ3LeKDU/iSF2JTgP6UmqQXayecJOlRb+CH/gf1JhsmcMvq+/JTGSHF262NO46Rwb0MjnoFthB4oS8GqWs8u3AwcT50BeFqdPNy1oVo7uaC329hRcLi0SlrDa1m9AW+q0WQ5vqVMOmKepmZ+3SbJ3QmMJcrs63p' }
  let(:fingerprint) { 'e2:2d:d6:1b:cc:86:2f:f8:e3:f6:97:ee:1d:53:bb:6a' }
  let(:helper_class) { Class.new { include PebbleReceiver::MikeHelpers } }
  
  context '.generate_fingerprint' do
    it 'returns correct fingerprint' do
      expect(helper_class.new.generate_fingerprint(key)).to eq(fingerprint)
    end
  end
end