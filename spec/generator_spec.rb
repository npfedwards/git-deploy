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
        expect(File.read('deploy/restart')).to include('Passenger')
      end
    end
  end

  it 'generates PHP/composer scripts with the php-composer template' do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        described_class.start(['--template', 'php-composer'])

        expect(File.read('deploy/before_restart')).to include('composer install')
        expect(File.read('deploy/restart')).to include('PHP')
      end
    end
  end

  it 'rejects unknown templates' do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        expect {
          described_class.start(['--template', 'django'])
        }.to output(/Unknown template/).to_stderr.and raise_error(SystemExit)
      end
    end
  end
end
