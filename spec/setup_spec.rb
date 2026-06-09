require 'spec_helper'

describe GitDeploy do
  describe '#setup' do
    let(:instance) { described_class.new([], remote: 'production', noop: true, shared: false, sudo: false) }
    let(:commands) { [] }

    before do
      allow(instance).to receive(:run_test).and_return(false)
      allow(instance).to receive(:run) do |cmd = nil, **_opts, &block|
        cmd = block.call([]) if block
        commands << cmd
      end
      allow(instance).to receive(:invoke)
      instance.send(:git_config)['remote -v'] = "production\tgit@example.com:/apps/demo (fetch)"
    end

    it 'initializes the remote repo with the current branch as HEAD' do
      instance.send(:git_config)['symbolic-ref -q HEAD'] = 'refs/heads/main'

      instance.setup

      init_cmd = commands.flatten.join(' && ')
      expect(init_cmd).to include('git init')
      expect(init_cmd).to include("sed -i'' -e 's/master/main/' .git/HEAD")
    end

    it 'skips HEAD rewrite when the current branch is master' do
      instance.send(:git_config)['symbolic-ref -q HEAD'] = 'refs/heads/master'

      instance.setup

      init_cmd = commands.flatten.join(' && ')
      expect(init_cmd).not_to include('sed')
    end
  end
end
