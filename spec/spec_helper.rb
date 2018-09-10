require 'bundler/setup'
Bundler.setup

require 'clamby' # and any other gems you need

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    # so that Command can keep doing what it always does.
    mocks.verify_partial_doubles = true
  end
end
