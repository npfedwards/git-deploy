require 'thor/group'

class GitDeploy::Generator < Thor::Group
  include Thor::Actions

  TEMPLATES = %w[rails-passenger rails-puma php-composer generic].freeze

  class_option :template, :type => :string, :default => 'rails-passenger'

  def self.source_root
    File.expand_path('../templates', __FILE__)
  end

  def verify_deploy_target
    if File.exist?('deploy') && !File.directory?('deploy')
      abort "Error: './deploy' exists but is a file. Remove or rename it before running init."
    end

    if File.directory?('deploy') && !Dir.empty?('deploy')
      say "Warning: deploy/ already exists and is not empty. Existing files will not be overwritten.", :yellow
    end
  end

  def copy_main_hook
    copy_hook 'after_push.sh', 'deploy/after_push'
  end

  def copy_restart_hook
    copy_hook 'restart.sh', 'deploy/restart'
  end

  def copy_restart_callbacks
    source = Dir[File.join(template_dir, 'before_restart.*')].first
    abort "Error: No before_restart script in template #{options[:template].inspect}" unless source
    copy_hook File.basename(source), 'deploy/before_restart'
  end

  private

  def template_dir
    @template_dir ||= begin
      name = options[:template] || 'rails-passenger'
      unless TEMPLATES.include?(name)
        abort "Error: Unknown template #{name.inspect}. Choose from: #{TEMPLATES.join(', ')}"
      end

      root = File.expand_path(self.class.source_root)
      dir = File.expand_path(name, root)
      unless dir.start_with?("#{root}#{File::SEPARATOR}") && File.directory?(dir)
        abort "Error: Unknown template #{name.inspect}. Choose from: #{TEMPLATES.join(', ')}"
      end
      dir
    end
  end

  def copy_hook(template, destination)
    return if File.exist?(destination)

    source = File.join(template_dir, template)
    abort "Error: Missing #{template} in template #{options[:template].inspect}" unless File.file?(source)

    copy_file source, destination
    chmod destination, 0744 unless File.executable? destination
  end
end
