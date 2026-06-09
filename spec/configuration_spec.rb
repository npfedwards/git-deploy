require 'spec_helper'

describe GitDeploy::Configuration do

  subject {
    mod = described_class
    obj = Object.new
    opt = options
    (class << obj; self; end).class_eval do
      include mod
      mod.private_instance_methods.each {|m| public m }
      define_method(:options) { opt }
    end
    obj
  }

  let(:options) { {:remote => 'production'} }

  def stub_git_config(cmd, value)
    subject.git_config[cmd] = value
  end

  def stub_remote_url(url, remote = options[:remote])
    stub_git_config("remote -v", "#{remote}\t#{url} (fetch)")
  end

  describe '#branch' do
    it 'uses the current branch when HEAD is on main' do
      stub_git_config('symbolic-ref -q HEAD', 'refs/heads/main')
      expect(subject.branch).to eq('main')
    end

    it 'uses master when no symbolic ref is available' do
      stub_git_config('symbolic-ref -q HEAD', nil)
      expect(subject.branch).to eq('master')
    end

    it 'uses master when on the master branch' do
      stub_git_config('symbolic-ref -q HEAD', 'refs/heads/master')
      expect(subject.branch).to eq('master')
    end
  end

  describe '#tracked_branch' do
    it 'returns the branch name for the current HEAD' do
      stub_git_config('symbolic-ref -q HEAD', 'refs/heads/main')
      stub_git_config('config branch.main.merge', 'refs/heads/main')
      expect(subject.tracked_branch).to eq('main')
    end
  end

  describe '#remote_for' do
    it 'returns the remote tracking a branch' do
      stub_git_config('config branch.main.remote', 'production')
      expect(subject.remote_for('refs/heads/main')).to eq('production')
    end
  end

  describe "extracting user/host from remote url" do
    context "ssh url" do
      before { stub_remote_url 'ssh://jon%20doe@example.com:88/path/to/app' }

      it { expect(subject.host).to eq('example.com') }
      it { expect(subject.remote_port).to eq(88) }
      it { expect(subject.remote_user).to eq('jon doe') }
      it { expect(subject.deploy_to).to eq('/path/to/app') }
    end

    context "scp-style" do
      before { stub_remote_url 'git@example.com:/path/to/app' }

      it { expect(subject.host).to eq('example.com') }
      it { expect(subject.remote_port).to be_nil }
      it { expect(subject.remote_user).to eq('git') }
      it { expect(subject.deploy_to).to eq('/path/to/app') }
    end

    context "scp-style with home" do
      before { stub_remote_url 'git@example.com:~/path/to/app' }

      it { expect(subject.host).to eq('example.com') }
      it { expect(subject.remote_port).to be_nil }
      it { expect(subject.remote_user).to eq('git') }
      it { expect(subject.deploy_to).to eq('~/path/to/app') }
    end

    context "scp-style relative path" do
      it 'resolves against the remote home directory' do
        instance = GitDeploy.new([], remote: 'production', noop: true)
        instance.send(:git_config)['remote -v'] = "production\tgit@example.com:apps/myapp (fetch)"
        allow(instance).to receive(:run).with('echo $HOME').and_return("/home/git\n")

        expect(instance.send(:deploy_to)).to eq('/home/git/apps/myapp')
      end
    end

    context "pushurl only" do
      before {
        remote = options.fetch(:remote)
        url = 'git@example.com:/path/to/app'
        stub_git_config("remote -v", "#{remote}\t\n#{remote}\t#{url} (push)")
      }

      it { expect(subject.host).to eq('example.com') }
      it { expect(subject.remote_user).to eq('git') }
    end
  end

end
