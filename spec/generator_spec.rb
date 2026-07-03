require 'spec_helper'
require 'tmpdir'
require 'fileutils'
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

  it 'rejects path traversal in template names' do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        expect {
          described_class.start(['--template', '../rails-passenger'])
        }.to output(/Unknown template/).to_stderr.and raise_error(SystemExit)
      end
    end
  end

  it 'refuses to run when deploy exists as a file' do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        File.write('deploy', '#!/bin/sh')

        expect {
          described_class.start([])
        }.to output(/deploy.*is a file/).to_stderr.and raise_error(SystemExit)

        expect(File.directory?('deploy')).to be false
      end
    end
  end

  it 'warns and preserves existing files when deploy is not empty' do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p('deploy')
        File.write('deploy/custom', 'keep me')

        expect {
          described_class.start([])
        }.to output(/already exists/).to_stdout

        expect(File.read('deploy/custom')).to eq('keep me')
        expect(File.executable?('deploy/after_push')).to be true
      end
    end
  end

  it 'generates a PHP restart script that fails when reload fails' do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        described_class.start(['--template', 'php-composer'])

        restart = File.read('deploy/restart')
        expect(restart).not_to include('|| true')
        expect(restart).to include('exit 1')
      end
    end
  end
end
