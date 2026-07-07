require 'spec_helper'
require 'yaml'

def load_workflow(path)
  # Psych treats bare `on:` as boolean true; GitHub Actions uses it as the trigger key.
  YAML.load(File.read(path).gsub(/^on:/, 'trigger:'))
end

describe 'GitHub workflows' do
  let(:ci) { load_workflow('.github/workflows/ci.yml') }
  let(:release) { load_workflow('.github/workflows/release.yml') }

  it 'verifies the gem builds on every CI run' do
    expect(ci['jobs']).to have_key('build-gem')
  end

  it 'publishes to RubyGems when a version tag is pushed' do
    expect(release['trigger']['push']['tags']).to include('v*')
    expect(release['jobs']).to have_key('release')
  end

  it 'runs the test suite before publishing' do
    steps = release.dig('jobs', 'release', 'steps').map { |s| s['run'] }.compact
    expect(steps).to include('bundle exec rspec')
  end

  it 'publishes to RubyGems with the API key secret' do
    steps = release.dig('jobs', 'release', 'steps')
    publish = steps.find { |s| s['name'] == 'Build and publish to RubyGems' }
    expect(publish).not_to be_nil
    expect(publish['run']).to include('gem push')
    expect(publish['env']).to include('GEM_HOST_API_KEY')
  end

  it 'builds the gem on the latest supported Ruby' do
    ruby = ci.dig('jobs', 'build-gem', 'steps').
      find { |s| s['uses'] == 'ruby/setup-ruby@v1' }['with']['ruby-version']
    expect(ruby).to eq('4.0')
  end

  it 'verifies the release tag matches the gemspec version' do
    steps = release.dig('jobs', 'release', 'steps').map { |s| s['name'] }
    expect(steps).to include('Verify tag matches gemspec version')
  end

  it 'verifies the changelog documents the release' do
    steps = release.dig('jobs', 'release', 'steps').map { |s| s['name'] }
    expect(steps).to include('Verify CHANGELOG documents this release')
  end

  it 'creates a GitHub release from the changelog section' do
    steps = release.dig('jobs', 'release', 'steps')
    gh_release = steps.find { |s| s['uses']&.start_with?('softprops/action-gh-release') }
    expect(gh_release).not_to be_nil
    expect(gh_release['with']['body_path']).to eq('release-notes.md')
  end
end
