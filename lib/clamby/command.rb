module Clamby
  # Interface with the system. Builds and runs the command.
  class Command
    EXECUTABLES = %w(clamscan clamdscan freshclam)

    # Array containing the complete command line.
    attr_accessor :command

    # Returns the appropriate scan executable, based on clamd being used.
    def self.scan_executable
      return 'clamdscan' if Clamby.config[:daemonize]
      return 'clamscan'
    end

    # Perform a ClamAV scan on the given path.
    def self.scan(path)
      return nil unless file_exists?(path)

      args = [path, '--no-summary']

      if Clamby.config[:daemonize]
        args << '--fdpass' if Clamby.config[:fdpass]
        args << '--stream' if Clamby.config[:stream]
        args << "--config-file=#{Clamby.config[:config_file]}" if Clamby.config[:config_file]
      end

      new.run scan_executable, *args

      case $CHILD_STATUS.exitstatus
      when 0
        return false
      when 2
        # clamdscan returns 2 whenever error other than a detection happens
        if Clamby.config[:error_clamscan_client_error] && Clamby.config[:daemonize]
          raise Clamby::ClamscanClientError.new("Clamscan client error")
        end

        # returns true to maintain legacy behavior
        return true
      else
        return true unless Clamby.config[:error_file_virus]

        raise Clamby::VirusDetected.new("VIRUS DETECTED on #{Time.now}: #{path}")
      end
    end

    # Update the virus definitions.
    def self.freshclam
      new.run 'freshclam'
    end

    # Show the ClamAV version. Also acts as a quick check if ClamAV functions.
    def self.clamscan_version
      new.run 'clamscan', '--version'
    end

    # Run the given commands via a system call.
    # The executable must be one of the permitted ClamAV executables.
    # The arguments will be combined with default arguments if needed.
    # The arguments are sorted alphabetically before being passed to the system.
    #
    # Examples:
    #   run('clamscan', file, '--verbose')
    #   run('clamscan', '-V')
    def run(executable, *args)
      raise "`#{executable}` is not permitted" unless EXECUTABLES.include?(executable)
      self.command = args | default_args
      self.command = command.sort.unshift(executable)

      system(*self.command, system_options)
    end

    private

    def default_args
      args = []
      args << '--quiet' if Clamby.config[:output_level] == 'low'
      args << '--verbose' if Clamby.config[:output_level] == 'high'
      args
    end

    # This applies to the `system` call itself; does not end up in the command.
    def system_options
      if Clamby.config[:output_level] == 'off'
        { out: File::NULL }
      else
        {}
      end
    end

    def self.file_exists?(path)
      return true if File.file?(path)

      if Clamby.config[:error_file_missing]
        raise Clamby::FileNotFound.new("File not found: #{path}")
      else
        puts "FILE NOT FOUND on #{Time.now}: #{path}"
        return false
      end
    end
  end
end
