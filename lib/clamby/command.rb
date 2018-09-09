module Clamby
  # Interface with the system. Builds and runs the command.
  class Command
    EXECUTABLES = %w(clamscan clamdscan freshclam)

    # Returns the appropriate scan executable, based on clamd being used.
    def self.scan_executable
      return 'clamdscan' if Clamby.config[:daemonize]
      return 'clamscan'
    end

    # Perform a ClamAV scan on the given path.
    def self.scan(path)
      file_exists?(path)

      args = %w[--no-summary]
      if Clamby.config[:daemonize]
        args << '--fdpass' if Clamby.config[:fdpass]
        args << '--stream' if Clamby.config[:stream]
      end

      new.run scan_executable, *args
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
      args = args | default_args

      system(
        *args.sort.unshift(executable),
        system_options
      )
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
      return false if path.nil?
      return true if File.file?(path)

      if Clamby.config[:error_file_missing]
        raise Exceptions::FileNotFound.new("File not found: #{path}")
      else
        puts "FILE NOT FOUND on #{Time.now}: #{path}"
        return false
      end
    end
  end
end
