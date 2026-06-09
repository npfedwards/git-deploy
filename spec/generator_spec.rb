require 'spec_helper'
require 'tmpdir'
require 'git_deploy/generator'

describe GitDeploy::Generator do
  it 'generates deploy callback scripts in the current directory' do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        described_class.start([])

        expect(File.executable?('deploy/after_push')).to be true
        expect(File.executable?('deploy/restart')).to be true
        expect(File.executable?('deploy/before_restart')).to be true
      end
    end
  end
end
