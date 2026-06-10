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
end
