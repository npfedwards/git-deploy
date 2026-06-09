require 'spec_helper'

describe GitDeploy do
  it 'exposes the upstream CLI commands' do
    commands = described_class.all_commands.keys
    expect(commands).to include(
      'init', 'setup', 'hooks', 'restart', 'rerun', 'rollback', 'log', 'upload'
    )
  end
end
