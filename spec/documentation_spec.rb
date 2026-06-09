require 'spec_helper'

describe 'Documentation' do
  it 'ships README.md and AGENTS.md instead of README.markdown' do
    expect(File).to exist('README.md')
    expect(File).to exist('AGENTS.md')
    expect(File).not_to exist('README.markdown')
  end

  it 'documents required remote in README' do
    readme = File.read('README.md')
    expect(readme).to include('-r')
    expect(readme).to include('AGENTS.md')
  end
end
