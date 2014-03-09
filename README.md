# Clamby

This gem depends on the `clamscan` and `freshclam` daemons to be installed already.

If you have a file upload on your site and you do not scan the files for viruses then you not only compromise your software, but also the users of the software and their files. This gem's function is to simply scan a given file.

#Configuration

Configuration is rather limited right now. You can exclude the check if `clamscan` exists which will save a bunch of time for scanning your files. However, for development purposes, your machine may not have `clamscan` installed and you may wonder why it's not working properly. This is just to give you a reminder to install `clamscan` on your development machine and production machine.

	Clamby.configure do |config|
		config.check = false
	end


# Dependencies

##Ubuntu

`sudo apt-get install clamav`

##Apple

`brew install clamav`