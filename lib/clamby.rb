require "clamby/version"
require "clamby/exception"
module Clamby

  @config = {
    :check => true,
    :error_clamscan_missing => true,
    :error_file_missing => true,
    :error_file_virus => false
  }

  @valid_config_keys = @config.keys

  def self.configure(opts = {})
    opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
  end

  def self.safe?(path)
    if self.scanner_exists?
      if file_exists?(path)
        scanner = system("clamdscan #{path} --no-summary")
        if scanner
          return true
        elsif not scanner
          if @config[:error_file_virus]
            raise Exceptions::VirusDetected.new("VIRUS DETECTED on #{Time.now}: #{path}")
          else
            puts "VIRUS DETECTED on #{Time.now}: #{path}"
            return false
          end
        end
      else
        return nil
      end
    else
      return nil
    end
  end

  def self.virus?(path)
    if self.scanner_exists?
      if file_exists?(path)
        scanner = system("clamdscan #{path} --no-summary")
        if scanner
          return false
        elsif not scanner
          if @config[:error_file_virus]
            raise Exceptions::VirusDetected.new("VIRUS DETECTED on #{Time.now}: #{path}")
          else
            puts "VIRUS DETECTED on #{Time.now}: #{path}"
            return true
          end
        end
      else
        return nil
      end
    else
      return nil
    end
  end

  def self.scanner_exists?
    if @config[:check]
      scanner = system('clamdscan -V')
      if not scanner
        if @config[:error_clamdscan_missing]
          raise Exceptions::clamdscanMissing.new("clamdscan application not found. Check your installation and path.")
        else
          puts "clamdscan NOT FOUND"
          return false
        end
      else
        return true
      end
    else
      return true
    end
  end

  def self.file_exists?(path)
    if File.file?(path)
      return true
    else
      if @config[:error_file_missing]
        raise Exceptions::FileNotFound.new("File not found: #{path}")
      else
        puts "FILE NOT FOUND on #{Time.now}: #{path}"
        return false
      end
    end
  end

  def self.update
    system("freshclam")
  end

  def self.config
    @config
  end
end
