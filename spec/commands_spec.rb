require 'spec_helper'
require 'tmpdir'

describe GitDeploy do
  describe '#upload' do
    it 'copies local files to the remote app directory' do
      instance = described_class.new([], remote: 'production', noop: true)
      uploads = {}

      allow(instance).to receive(:scp_upload) { |files| uploads.merge!(files) }
      instance.send(:git_config)['remote -v'] = "production\tgit@example.com:/apps/demo (fetch)"

      Dir.mktmpdir do |dir|
        file = File.join(dir, 'config.yml')
        File.write(file, 'test')

        instance.upload(file)

        expect(uploads[file]).to eq(File.join('/apps/demo', file))
      end
    end
  end

  describe '#restart' do
    it 'runs the deploy restart script on the server' do
      instance = described_class.new([], remote: 'production', noop: true)
      commands = []

      allow(instance).to receive(:run) { |cmd| commands << cmd }
      instance.send(:git_config)['remote -v'] = "production\tgit@example.com:/apps/demo (fetch)"

      instance.restart

      expect(commands.first).to include('deploy/restart')
    end
  end
end
