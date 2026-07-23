require 'spec_helper'
require 'git_deploy/changelog'

describe GitDeploy::Changelog do
  describe '.categorize' do
    it 'maps conventional commit types to Keep a Changelog headings' do
      expect(described_class.categorize('feat: add download')).to eq('Added')
      expect(described_class.categorize('fix: path resolution')).to eq('Fixed')
      expect(described_class.categorize('docs: refresh README')).to eq('Changed')
      expect(described_class.categorize('chore: deps')).to be_nil
    end
  end

  describe '.format_entry' do
    it 'capitalizes the subject and marks breaking changes' do
      expect(described_class.format_entry('feat: add download')).
        to eq('Add download')
      expect(described_class.format_entry('feat!: require remote')).
        to eq('**BREAKING:** Require remote')
    end
  end

  describe '.group_commits' do
    it 'groups and deduplicates entries by category' do
      groups = described_class.group_commits([
        'feat: add download',
        'fix: path resolution',
        'Merge pull request #12',
        'chore: ignore tmp'
      ])

      expect(groups['Added']).to eq(['Add download'])
      expect(groups['Fixed']).to eq(['Path resolution'])
      expect(groups.key?('Changed')).to be false
    end
  end

  describe '.render_section' do
    it 'renders a Keep a Changelog version section' do
      section = described_class.render_section('0.9.0', '2026-07-04', {
        'Added' => ['Download command'],
        'Fixed' => ['Remote path resolution']
      })

      expect(section).to include('## [0.9.0] - 2026-07-04')
      expect(section).to include('### Added')
      expect(section).to include('- Download command')
      expect(section).to include('### Fixed')
    end
  end

  describe '.update_content' do
    let(:base) do
      described_class::HEADER + "\n#{described_class::UNRELEASED}\n\n"
    end

    it 'inserts a new version section after Unreleased' do
      updated = described_class.update_content(base, '0.9.0',
        date: '2026-07-04',
        groups: { 'Added' => ['Download command'] })

      expect(updated).to include("## [Unreleased]\n\n## [0.9.0]")
      expect(updated).to include('- Download command')
    end

    it 'aborts when the version section already exists' do
      content = base + "## [0.9.0] - 2026-07-04\n\n"
      expect {
        described_class.update_content(content, '0.9.0',
          date: '2026-07-04', groups: { 'Added' => ['X'] })
      }.to output(/already has a section/).to_stderr.and raise_error(SystemExit)
    end
  end

  describe '.extract_section' do
    let(:content) do
      <<~CHANGELOG
        ## [Unreleased]

        ## [0.9.0] - 2026-07-04

        ### Added
        - Download command

        ## [0.8.0] - 2026-06-10
      CHANGELOG
    end

    it 'returns the body for a version section' do
      body = described_class.extract_section(content, '0.9.0')
      expect(body).to include('### Added')
      expect(body).to include('- Download command')
      expect(body).not_to include('0.8.0')
    end
  end

  describe '.verify_version!' do
    it 'aborts when the version is missing' do
      expect {
        described_class.verify_version!("## [Unreleased]\n", '0.9.0')
      }.to output(/no entry for version 0.9.0/).to_stderr.and raise_error(SystemExit)
    end
  end

  describe '.gemspec_version' do
    it 'reads the version from git-deploy-ng.gemspec' do
      expect(described_class.gemspec_version).to eq('0.9.1')
    end
  end
end
