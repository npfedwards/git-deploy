require 'uri'
require 'cgi'
require 'forwardable'

class GitDeploy
  module Configuration
    private

    extend Forwardable
    def_delegator :remote_url, :host
    def_delegator :remote_url, :port, :remote_port

    def deploy_to
      @deploy_to ||= begin
        remote_url
        normalize_deploy_path(
          GitDeploy::RemotePath.deploy_path(remote_url_string) { remote_home }
        )
      end
    end

    def remote_url_string(remote = options[:remote])
      remote_urls(remote).first
    end

    def normalize_deploy_path(path)
      path.start_with?('/~/') ? path[1..-1] : path
    end

    def remote_user
      @user ||= begin
        user = remote_url.user
        user ? CGI.unescape(user) : `whoami`.chomp
      end
    end

    def branch
      @branch ||= begin
        ref = current_branch
        ref && !ref.empty? ? normalize_branch(ref) : 'master'
      end
    end

    def git_config
      @git_config ||= Hash.new do |cache, cmd|
        git = ENV['GIT'] || 'git'
        out = `#{git} #{cmd}`
        if $?.success? then cache[cmd] = out.chomp
        else cache[cmd] = nil
        end
        cache[cmd]
      end
    end

    def remote_urls(remote)
      git_config["remote -v"].to_s.split("\n").
        select {|l| l =~ /^#{remote}\t.+/ }.
        map {|l| l.split("\t")[1].sub(/\s+\(.+?\)$/, '') }
    end

    def remote_url(remote = options[:remote])
      @remote_url ||= {}
      @remote_url[remote] ||= begin
        url = remote_urls(remote).first
        if url.nil?
          require_remote! if remote.nil? || remote.to_s.strip.empty?
          abort "Error: Remote url not found for remote #{remote.inspect}"
        elsif url =~ /(^|@)github\.com\b/
          abort "Error: Remote url for #{remote.inspect} points to GitHub. Can't deploy there!"
        else
          url = 'ssh://' + url.sub(%r{:/?}, '/') unless url =~ %r{^[\w-]+://}
          begin
            url = URI.parse url
          rescue
            abort "Error parsing remote url #{url}"
          end
        end
        url
      end
    end

    def current_branch
      git_config['symbolic-ref -q HEAD']
    end

    def tracked_branch
      branch = current_branch && tracked_for(current_branch)
      normalize_branch(branch) if branch
    end

    def normalize_branch(branch)
      branch.sub('refs/heads/', '')
    end

    def remote_for(branch)
      git_config['config branch.%s.remote' % normalize_branch(branch)]
    end

    def tracked_for(branch)
      git_config['config branch.%s.merge' % normalize_branch(branch)]
    end

    def require_remote!
      remote = options[:remote]
      if remote.nil? || remote.to_s.strip.empty?
        abort "Error: Specify a remote with -r (e.g. git deploy setup -r production)"
      end
    end
  end
end
