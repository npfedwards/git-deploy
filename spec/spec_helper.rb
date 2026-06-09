require 'simplecov'
SimpleCov.minimum_coverage 80
SimpleCov.start

require 'rspec'
require 'rspec/mocks'
require 'git_deploy'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
