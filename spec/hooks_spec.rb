require 'spec_helper'

describe GitDeploy do
  describe '#hooks' do
    it 'uploads the post-receive hook to the remote repository' do
      instance = described_class.new([], remote: 'production', noop: true)
      uploads = {}

      allow(instance).to receive(:scp_upload) { |files| uploads.merge!(files) }
      allow(instance).to receive(:run)
      instance.send(:git_config)['remote -v'] = "production\tgit@example.com:/apps/demo (fetch)"

      instance.hooks

      expect(uploads.values).to include('/apps/demo/.git/hooks/post-receive')
    end
  end
end
