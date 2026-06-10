#!/usr/bin/env ruby
oldrev, newrev = ARGV

def run(cmd)
  exit($?.exitstatus) unless system "umask 002 && #{cmd}"
end

RAILS_ENV   = ENV['RAILS_ENV'] || 'production'
use_bundler = File.file? 'Gemfile'
rake_cmd    = use_bundler ? 'bundle exec rake' : 'rake'

if use_bundler
  bundler_args = ['--deployment']
  BUNDLE_WITHOUT = ENV['BUNDLE_WITHOUT'] || 'development:test'
  bundler_args << '--without' << BUNDLE_WITHOUT unless BUNDLE_WITHOUT.empty?

  run "bundle install #{bundler_args.join(' ')}"
end

if File.file? 'Rakefile'
  tasks = []

  if File.exist?('db/migrate')
    num_migrations = `git diff #{oldrev} #{newrev} --diff-filter=A --name-only -z -- db/migrate`.split("\0").size
  else
    num_migrations = 0
  end

  tasks << "db:migrate" if num_migrations > 0

  asset_paths = %w[app/assets app/javascript config/importmap.rb package.json yarn.lock]
  changed_assets = `git diff #{oldrev} #{newrev} --name-only -z -- #{asset_paths.join(' ')}`.split("\0")
  tasks << "assets:precompile" if changed_assets.size > 0

  run "#{rake_cmd} #{tasks.join(' ')} RAILS_ENV=#{RAILS_ENV}" if tasks.any?
end

run "git clean -x -f -- public/assets tmp/cache/assets" if Dir.exist?('public/assets')
