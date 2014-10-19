require 'spec_helper'

describe PebbleReceiver::Auther, :vcr do
  let(:key) { 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3pm2f5Cd/ryLof5xIrcWkaO5rDVwix5wKd39WWF2tI8CGP/Qp9hwbYJ3puH1MKu+8MZ8vKAMtlpo+eva93Z2Qt9WR2goPah45p4TDXeuCuvfAUzbLjluhVwTdR1Moj9npoE8IetF24MkGGUPy3KlZpYd0JBxJqyLBW5Odv2eGXglOxBigwzC2JlQ3LeKDU/iSF2JTgP6UmqQXayecJOlRb+CH/gf1JhsmcMvq+/JTGSHF262NO46Rwb0MjnoFthB4oS8GqWs8u3AwcT50BeFqdPNy1oVo7uaC329hRcLi0SlrDa1m9AW+q0WQ5vqVMOmKepmZ+3SbJ3QmMJcrs63p' }
  
  context '.auth' do
    it 'returns 1 for failed authentication' do
      expect_any_instance_of(PebbleReceiver::Auther).to receive(:validate_key).and_call_original
      expect(PebbleReceiver::Auth.start('dumb', 'fakekey')).to eq(1)
    end
    
    it 'returns 0 for successful authentication' do
      expect_any_instance_of(PebbleReceiver::Auther).to receive(:validate_key).and_call_original
      expect(PebbleReceiver::Auth.start('kris', key)).to eq(0)
    end
  end
end