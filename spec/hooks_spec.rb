require 'spec_helper'

describe GitDeploy do
  describe '#hooks' do
    it 'uploads the post-receive hook to the remote repository' do
      instance = described_class.new([], remote: 'production', noop: true)
      uploads = {}

      allow(instance).to receive(:scp_upload) { |files| uploads.merge!(files) }
      allow(instance).to receive(:run)
      allow(instance).to receive(:run_test).and_return(false)
      instance.send(:git_config)['remote -v'] = "production\tgit@example.com:/apps/demo (fetch)"

      instance.hooks

      expect(uploads.values).to include('/apps/demo/.git/hooks/post-receive')
    end

    it 'requires a remote name' do
      instance = described_class.new([], noop: true)

      expect { instance.hooks }.to output(/Specify a remote with -r/).to_stderr.and raise_error(SystemExit)
    end

    it 'refuses to overwrite an existing post-receive hook without --force' do
      instance = described_class.new([], remote: 'production', noop: true)
      instance.send(:git_config)['remote -v'] = "production\tgit@example.com:/apps/demo (fetch)"
      allow(instance).to receive(:run_test).with("[ -f /apps/demo/.git/hooks/post-receive ]").and_return(true)

      expect { instance.hooks }.to output(/already has a post-receive hook/).to_stderr.and raise_error(SystemExit)
    end
  end
end
