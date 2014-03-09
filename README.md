# Clamby

This gem depends on the `clamscan` and `freshclam` daemons to be installed already.

If you have a file upload on your site and you do not scan the files for viruses then you not only compromise your software, but also the users of the software and their files. This gem's function is to simply scan a given file.

#Configuration

Configuration is rather limited right now. You can exclude the check if `clamscan` exists which will save a bunch of time for scanning your files. However, for development purposes, your machine may not have `clamscan` installed and you may wonder why it's not working properly. This is just to give you a reminder to install `clamscan` on your development machine and production machine. You can add the following to a config file, `clamby_setup.rb` to your initializers directory.

    Clamby.configure do |config|
		config.check = false
	end


# Dependencies

***Ubuntu***

`sudo apt-get install clamav`

***Apple***

`brew install clamav`

#LICENSE

Copyright (c) 2014 kobaltz

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
