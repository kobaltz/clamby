require 'bundler/setup'
Bundler.setup

require 'open-uri'
require 'tempfile'

require 'clamby' # and any other gems you need

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    # so that Command can keep doing what it always does.
    mocks.verify_partial_doubles = true
  end

  def download(url)
    file = open(url)
    file.is_a?(StringIO) ? to_tempfile(file) : file
  end

  # OpenURI returns either Tempfile or StringIO depending of the size of
  # the response. We want to unify this and always return Tempfile.
  def to_tempfile(io)
    tempfile = Tempfile.new('tmp')
    tempfile.binmode
    ::OpenURI::Meta.init(tempfile, io)
    tempfile << io.string
    tempfile.rewind
    tempfile
  end
end
