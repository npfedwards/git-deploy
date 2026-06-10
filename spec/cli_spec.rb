require 'spec_helper'

describe GitDeploy do
  it 'exposes the upstream CLI commands' do
    commands = described_class.all_commands.keys
    expect(commands).to include(
      'init', 'setup', 'hooks', 'restart', 'rerun', 'rollback', 'log', 'upload'
    )
  end

  it 'allows init without a remote name' do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        expect { described_class.start(%w[init]) }.not_to raise_error
      end
    end
  end
end
