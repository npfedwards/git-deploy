require 'spec_helper'

describe GitDeploy do
  describe '#setup' do
    let(:instance) { described_class.new([], remote: 'production', noop: true, shared: false, sudo: false) }
    let(:commands) { [] }
    let(:run_tests) { {} }

    before do
      allow(instance).to receive(:run_test) do |cmd|
        run_tests[cmd] = false if run_tests[cmd].nil?
        run_tests[cmd]
      end
      allow(instance).to receive(:run) do |cmd = nil, **_opts, &block|
        cmd = block.call([]) if block
        commands << cmd
      end
      allow(instance).to receive(:invoke)
      instance.send(:git_config)['remote -v'] = "production\tgit@example.com:/apps/demo (fetch)"
    end

    it 'requires a remote name' do
      instance = described_class.new([], noop: true)

      expect { instance.setup }.to output(/Specify a remote with -r/).to_stderr.and raise_error(SystemExit)
    end

    it 'refuses to overwrite an existing post-receive hook without --force' do
      run_tests["[ -f /apps/demo/.git/hooks/post-receive ]"] = true

      expect { instance.setup }.to output(/already has a post-receive hook/).to_stderr.and raise_error(SystemExit)
    end

    it 'proceeds when post-receive exists and --force is given' do
      forced = described_class.new([], remote: 'production', noop: true, shared: false, sudo: false, force: true)
      allow(forced).to receive(:run_test) do |cmd|
        run_tests[cmd] = false if run_tests[cmd].nil?
        run_tests[cmd]
      end
      allow(forced).to receive(:run) do |cmd = nil, **_opts, &block|
        cmd = block.call([]) if block
        commands << cmd
      end
      allow(forced).to receive(:invoke)
      forced.send(:git_config)['remote -v'] = "production\tgit@example.com:/apps/demo (fetch)"
      run_tests["[ -f /apps/demo/.git/hooks/post-receive ]"] = true
      run_tests["test -x /apps/demo"] = true
      run_tests["[ -d /apps/demo/.git ]"] = true

      forced.setup

      expect(commands).not_to be_empty
    end

    it 'skips git init when the remote repo already exists' do
      run_tests["[ -d /apps/demo/.git ]"] = true

      instance.setup

      init_cmd = commands.flatten.join(' && ')
      expect(init_cmd).not_to include('git init')
      expect(init_cmd).to include('git config receive.denyCurrentBranch ignore')
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
