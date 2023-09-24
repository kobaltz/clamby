require "English"
require "clamby/command"
require "clamby/error"
require "clamby/version"

module Clamby
  DEFAULT_CONFIG = {
    :check => true,
    :daemonize => false,
    :config_file => nil,
    :error_clamscan_missing => true,
    :error_clamscan_client_error => false,
    :error_file_missing => true,
    :error_file_virus => false,
    :fdpass => false,
    :stream => false,
    :reload => false,
    :output_level => 'medium',
    :datadir => nil,
    :executable_path_clamscan => 'clamscan',
    :executable_path_clamdscan => 'clamdscan',
    :executable_path_freshclam => 'freshclam',
  }.freeze

  @config = DEFAULT_CONFIG.dup

  @valid_config_keys = @config.keys

  class << self
    attr_reader :config
    attr_reader :valid_config_keys
  end

  def self.configure(opts = {})
    if opts.delete(:silence_output)
      warn ':silence_output config is deprecated. Use :output_level => "off" instead.'
      opts[:output_level] = 'off'
    end

    opts.each {|k,v| config[k.to_sym] = v if valid_config_keys.include? k.to_sym}
  end

  def self.safe?(path)
    value = virus?(path)
    return nil if value.nil?
    ! value
  end

  def self.virus?(path)
    return nil unless scanner_exists?
    Command.scan path
  end

  def self.scanner_exists?
    return true unless config[:check]
    scanner = Command.clamscan_version

    return true if scanner
    return false unless config[:error_clamscan_missing]

    raise Clamby::ClamscanMissing.new("#{Command.scan_executable} not found. Check your installation and path.")
  end

  def self.update
    Command.freshclam
  end

  def self.daemonize?
    !! config[:daemonize]
  end
end
