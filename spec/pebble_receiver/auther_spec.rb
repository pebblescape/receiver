require 'spec_helper'

describe PebbleReceiver::Auther, :vcr do
  let(:key) { 'ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAxkFJTdh5sRcX3nb/6Uro1a6aAxF9Jhzg+8lwUI8Qg0Ihoh2Kl+DCB+nzFtT/E01QDapdK71/hKKgPDzqAkoKH2WVND6lyrZYyHk92zOnK+7g+D+ekNgF9/FGMd85iWG9tHneTsBQYjKO7xmEgg8CFritfcCQ5623eNDBrREBk5w64ZhG+V473jwrWPODPZ1OCdRamlpZ5BPzL7JRlXIN6ekjgtY9DyswxNkhpQ0+U0kygWtRmYGXzHk9xDP0psTgXFCH7mmtTHEMv3WhG+dlaOov2iOdN8hwOZpUOrqGm4wEAHxRsKKGc21Khv0yswm74HClNIpJjSNfK6YK32GNsw==' }
  let(:fakekey) { 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGgD0NvjUvFZjPBDXGaHnI8uU/cyZ3tzsDhDBw1ErVO81EoyJ+mW4biWhccDIke4sGQR5dGwgXT01UHJa580+soQSJWb2Yve+FRJW6cvhTTTwakAYDCzOdFVFMYqufd8EDE1hpaRtuZlBWCVpA5c9X2xNJNeV0sh/eRF4lH4P4RAHUOtAhTwMhbhemr0Irc6Ykdrc2nPbQUAhuXOv7uPsu+73zcY8OVExoYGB/uCxkDi08r6MzFY81CaurvvW5YcR8UyOJdh4SEo9hW+H0owIMOtYPRvfvsp5M3CuifG7ersY+PCw/KeyV6SO2/zFVR56QbUBmunedTAMGDRVQC01v' }

  context '.auth' do
    it 'returns 1 for failed authentication' do
      expect_any_instance_of(PebbleReceiver::Auther).to receive(:validate_key).and_call_original
      expect{ PebbleReceiver::Auth.start('dumb', fakekey) }.to raise_error(Excon::Errors::NotFound)
    end

    it 'returns 0 for successful authentication' do
      expect_any_instance_of(PebbleReceiver::Auther).to receive(:validate_key).and_call_original
      expect(PebbleReceiver::Auth.start('kris', key)).to eq(0)
    end

    it 'returns 1 for wrong username' do
      expect_any_instance_of(PebbleReceiver::Auther).to receive(:validate_key).and_call_original
      expect(PebbleReceiver::Auth.start('notkris', key)).to eq(1)
    end

    it 'returns 1 for obviously invalid key without calling Mike' do
      expect_any_instance_of(PebbleReceiver::Auther).to_not receive(:validate_key)
      expect(PebbleReceiver::Auth.start('kris', 'fakekey')).to eq(1)
    end
  end
end
