require "clamby/version"
require "clamby/exception"
module Clamby

  @config = {
    :check => true,
    :daemonize => false,
    :error_clamscan_missing => true,
    :error_file_missing => true,
    :error_file_virus => false,
    :fdpass => false
  }

  @valid_config_keys = @config.keys

  def self.configure(opts = {})
    opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
  end

  def self.safe?(path)
    value =  virus?(path)
    return nil if value.nil?
    ! value
  end

  # Assemble the system command to be called, including optional flags
  # @param [String] path path to the file being scanned
  # @return [String] command to be executed
  def self.system_command(path)
    command = clamd_executable_name
    command += ' --fdpass' if @config[:fdpass]
    command += " #{path}"
    command += ' --no-summary'
    command
  end

  def self.virus?(path)
    return nil unless scanner_exists?
    return nil unless file_exists?(path)
    scanner = system(system_command(path))

    return false if scanner
    return true unless @config[:error_file_virus]

    raise Exceptions::VirusDetected.new("VIRUS DETECTED on #{Time.now}: #{path}")
  end

  def self.scanner_exists?
    return true unless @config[:check]
    scanner = system(clamd_executable_name, '-V')

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
    system("freshclam")
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
