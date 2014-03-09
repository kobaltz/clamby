require "clamby/version"

module Clamby

  @config = {:check => true}

  @valid_config_keys = @config.keys

  def self.configure(opts = {})
    opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
  end

  def self.scan(path)
  	if self.scanner_exists?
  		if file_exists?(path)
  			scanner = system("clamscan #{path} --no-summary")
			if scanner
				return true
			elsif not scanner
				puts "VIRUS DETECTED on #{Time.now}: #{path}"
				return false
			end
		end
	end
  end

  def self.scanner_exists?
  	if @config[:check]
	  	scanner = system('clamscan')
	  	if not scanner
	  		puts "CLAMSCAN NOT FOUND"
	  		return false
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
		puts "FILE NOT FOUND on #{Time.now}: #{path}"
		return false
	end
  end

  def self.config
    @config
  end
end
