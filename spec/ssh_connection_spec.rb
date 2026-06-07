require 'spec_helper'

describe GitDeploy do
  describe 'SSH connection' do
    let(:instance) { described_class.new([], remote: 'production') }

    before do
      instance.send(:git_config)['remote -v'] = "production\tgit@example.com:/apps/demo (fetch)"
    end

    it 'advises installing ed25519 gems when SSH keys require them' do
      allow(Net::SSH).to receive(:start).and_raise(
        NotImplementedError,
        "unsupported key type `ssh-ed25519'\n * ed25519 (>= 1.2, < 2.0)"
      )

      expect { instance.send(:run_test, 'true') }.to raise_error(SystemExit, /gem install ed25519 bcrypt_pbkdf/)
    end

    it 're-raises unrelated SSH errors' do
      allow(Net::SSH).to receive(:start).and_raise(NotImplementedError, 'unexpected failure')

      expect { instance.send(:run_test, 'true') }.to raise_error(NotImplementedError, 'unexpected failure')
    end
  end
end
