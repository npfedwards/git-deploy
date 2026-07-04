require 'uri'

class GitDeploy
  module RemotePath
    SCP_PATH = %r{\A(?:[^@]+@)?[^:]+:(.+)\z}

    def self.raw_path(url)
      if url.nil? || url.to_s.strip.empty?
        abort "Error: No deploy remote URL configured. Specify a remote with -r."
      end

      if url.match?(%r{\A[\w-]+://})
        URI.parse(url).path
      else
        match = url.match(SCP_PATH)
        match ? match[1] : url
      end
    end

    def self.deploy_path(url, home: nil)
      path = raw_path(url)
      return path if path.start_with?('/', '~')

      home = yield if home.nil? && block_given?
      File.join(home, path)
    end
  end
end
