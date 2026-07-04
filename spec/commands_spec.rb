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

  describe '#download' do
    it 'copies remote files into the local app directory' do
      instance = described_class.new([], remote: 'production', noop: true)
      downloads = {}

      allow(instance).to receive(:scp_download) { |files| downloads.merge!(files) }
      instance.send(:git_config)['remote -v'] = "production\tgit@example.com:/apps/demo (fetch)"

      instance.download('log/deploy.log')

      expect(downloads['/apps/demo/log/deploy.log']).to eq('log/deploy.log')
    end

    it 'requires a remote' do
      instance = described_class.new([], noop: true)

      expect {
        instance.download('index.html')
      }.to output(/Specify a remote with -r/).to_stderr.and raise_error(SystemExit)
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
