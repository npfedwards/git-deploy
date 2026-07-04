require 'date'

class GitDeploy
  module Changelog
    HEADER = <<~HEADER
      # Changelog

      All notable changes to this project will be documented in this file.

      The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
      and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

    HEADER

    UNRELEASED = '## [Unreleased]'

    CATEGORY_FOR = {
      'feat' => 'Added',
      'fix'  => 'Fixed',
      'docs' => 'Changed',
      'perf' => 'Changed'
    }.freeze

    CATEGORY_ORDER = ['Added', 'Changed', 'Fixed', 'Removed', 'Deprecated', 'Security'].freeze

    module_function

    def gemspec_version(path = 'git-deploy-ng.gemspec')
      line = File.readlines(path).find { |l| l =~ /gem\.version\s*=/ }
      line[/['"]([^'"]+)['"]/, 1]
    end

    def categorize(subject)
      type = subject[/\A(\w+)(?:\([^)]+\))?!?:/, 1]
      return nil unless type

      CATEGORY_FOR[type]
    end

    def format_entry(subject)
      body = subject.sub(/\A\w+(?:\([^)]+\))?!?:\s*/, '')
      breaking = subject.include?('!:') || subject.match?(/\A\w+!:/)
      entry = body.empty? ? subject : body[0].upcase + body[1..]
      breaking ? "**BREAKING:** #{entry}" : entry
    end

    def group_commits(subjects)
      groups = Hash.new { |h, k| h[k] = [] }
      subjects.each do |subject|
        next if subject.start_with?('Merge ')
        category = categorize(subject) || next
        groups[category] << format_entry(subject)
      end
      groups.each_value(&:uniq!)
      groups
    end

    def render_section(version, date, groups)
      lines = ["## [#{version}] - #{date}", '']
      CATEGORY_ORDER.each do |category|
        entries = groups[category]
        next if entries.nil? || entries.empty?

        lines << "### #{category}"
        entries.sort.each { |entry| lines << "- #{entry}" }
        lines << ''
      end
      lines.join("\n").rstrip + "\n"
    end

    def extract_section(content, version)
      pattern = /^## \[#{Regexp.escape(version)}\][^\n]*\n(.*?)(?=^## \[|\z)/m
      match = content.match(pattern)
      return nil unless match

      body = match[1].strip
      body.empty? ? nil : body
    end

    def verify_version!(content, version)
      section = extract_section(content, version)
      abort "Error: CHANGELOG.md has no entry for version #{version}" if section.nil?
      section
    end

    def update_content(content, version, date:, groups:)
      section = render_section(version, date, groups)
      if content.nil? || content.dup.force_encoding(Encoding::UTF_8).strip.empty?
        return HEADER + "\n#{UNRELEASED}\n\n" + section + "\n"
      end

      content = content.dup.force_encoding(Encoding::UTF_8)

      unless content.include?(UNRELEASED)
        abort "Error: CHANGELOG.md is missing the #{UNRELEASED} heading"
      end

      if content.match?(/^## \[#{Regexp.escape(version)}\]/m)
        abort "Error: CHANGELOG.md already has a section for version #{version}"
      end

      content.sub("#{UNRELEASED}\n", "#{UNRELEASED}\n\n#{section}\n")
    end

    def git_log_subjects(since_ref, until_ref: 'HEAD')
      range = since_ref ? "#{since_ref}..#{until_ref}" : until_ref
      `git log #{range} --pretty=format:%s --no-merges`.
        force_encoding(Encoding::UTF_8).
        split("\n", -1).
        reject(&:empty?)
    end

    def latest_tag
      tag = `git describe --tags --abbrev=0 2>/dev/null`.strip
      tag.empty? ? nil : tag
    end

    def update_file(path, version, date: Date.today.iso8601, since_ref: latest_tag)
      subjects = git_log_subjects(since_ref)
      groups = group_commits(subjects)
      content = File.exist?(path) ? File.read(path) : nil
      File.write(path, update_content(content, version, date: date, groups: groups))
    end
  end
end
