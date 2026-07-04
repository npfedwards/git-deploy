require 'spec_helper'
require 'git_deploy/remote_path'

describe GitDeploy::RemotePath do
  describe '.raw_path' do
    it 'returns a relative path from scp-style remotes' do
      expect(described_class.raw_path('git@example.com:apps/myapp')).to eq('apps/myapp')
    end

    it 'returns an absolute path from scp-style remotes' do
      expect(described_class.raw_path('git@example.com:/apps/myapp')).to eq('/apps/myapp')
    end

    it 'returns a home-relative path from scp-style remotes' do
      expect(described_class.raw_path('git@example.com:~/apps/myapp')).to eq('~/apps/myapp')
    end

    it 'returns the path from ssh URLs' do
      expect(described_class.raw_path('ssh://git@example.com:88/apps/myapp')).to eq('/apps/myapp')
    end

    it 'aborts when the url is missing' do
      expect {
        described_class.raw_path(nil)
      }.to output(/No deploy remote URL configured/).to_stderr.and raise_error(SystemExit)
    end
  end

  describe '.deploy_path' do
    it 'joins relative paths with the remote home directory' do
      expect(described_class.deploy_path('git@example.com:apps/myapp') { '/home/git' }).
        to eq('/home/git/apps/myapp')
    end

    it 'leaves absolute paths unchanged' do
      expect(described_class.deploy_path('git@example.com:/var/www/app', home: '/home/git')).
        to eq('/var/www/app')
    end

    it 'leaves home-relative paths unchanged' do
      expect(described_class.deploy_path('git@example.com:~/apps/myapp', home: '/home/git')).
        to eq('~/apps/myapp')
    end
  end
end
