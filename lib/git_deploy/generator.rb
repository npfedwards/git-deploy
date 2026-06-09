require 'thor/group'

class GitDeploy::Generator < Thor::Group
  include Thor::Actions

  TEMPLATES = %w[rails-passenger rails-puma php-composer generic].freeze

  class_option :template, :type => :string, :default => 'rails-passenger'

  def self.source_root
    File.expand_path('../templates', __FILE__)
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
      dir = File.join(self.class.source_root, name)
      unless File.directory?(dir)
        abort "Error: Unknown template #{name.inspect}. Choose from: #{TEMPLATES.join(', ')}"
      end
      dir
    end
  end

  def copy_hook(template, destination)
    source = File.join(template_dir, template)
    abort "Error: Missing #{template} in template #{options[:template].inspect}" unless File.file?(source)

    copy_file source, destination
    chmod destination, 0744 unless File.executable? destination
  end
end
