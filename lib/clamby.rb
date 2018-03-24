require "English"
require "clamby/version"
require "clamby/exception"
module Clamby
  DEFAULT_CONFIG = {
    :check => true,
    :daemonize => false,
    :error_clamscan_missing => true,
    :error_clamscan_client_error => false,
    :error_file_missing => true,
    :error_file_virus => false,
    :fdpass => false,
    :silence_output => false,
    :stream => false
  }.freeze

  @config = DEFAULT_CONFIG.dup

  @valid_config_keys = @config.keys

  def self.configure(opts = {})
    opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
  end

  def self.safe?(path)
    value = virus?(path)
    return nil if value.nil?
    ! value
  end

  # Assemble the system command to be called, including optional flags
  # @param [String] path path to the file being scanned
  # @return [String] command to be executed
  def self.system_command(path)
    command = [].tap do |cmd|
      cmd << clamd_executable_name
      cmd << '--fdpass' if @config[:fdpass]
      cmd << '--stream' if @config[:stream] && @config[:daemonize]
      cmd << path
      cmd << '--no-summary'
      cmd << { out: File::NULL } if @config[:silence_output]
    end
    command
  end

  def self.virus?(path)
    return nil unless scanner_exists?
    return nil unless file_exists?(path)
    system(*system_command(path))

    case $CHILD_STATUS.exitstatus
    when 0
      return false
    when 2
      # clamdscan returns 2 whenever error other than a detection happens
      if @config[:error_clamscan_client_error] && @config[:daemonize]
        raise Exceptions::ClamscanClientError.new("Clamscan client error")
      end

      # returns true to maintain legacy behavior
      return true
    else
      return true unless @config[:error_file_virus]

      raise Exceptions::VirusDetected.new("VIRUS DETECTED on #{Time.now}: #{path}")
    end
  end

  def self.scanner_exists?
    return true unless @config[:check]
    scanner = system(clamd_executable_name, '-V', @config[:silence_output] ? { out: File::NULL } : {})

    return true if scanner
    return false unless @config[:error_clamscan_missing]

    raise Exceptions::ClamscanMissing.new("#{clamd_executable_name} application not found. Check your installation and path.")
  end

  def self.file_exists?(path)
    return false if path.nil?
    return true if File.file?(path)

    if @config[:error_file_missing]
      raise Exceptions::FileNotFound.new("File not found: #{path}")
    else
      puts "FILE NOT FOUND on #{Time.now}: #{path}"
      return false
    end
  end

  def self.update
    system("freshclam", @config[:silence_output] ? { out: File::NULL } : {})
  end

  def self.config
    @config
  end

  def self.clamd_executable_name(daemonize: false)
    daemonize? ? "clamdscan" : "clamscan"
  end

  def self.daemonize?
    !! @config[:daemonize]
  end
end
