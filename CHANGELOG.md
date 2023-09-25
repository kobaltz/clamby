# v1.6.10
 - Moved from Travis CI to GitHub Actions

# v1.6.9
 - [AndreasRonnqvistCytiva](https://github.com/kobaltz/clamby/commits?author=AndreasRonnqvistCytiva)  - Allow reload option #44

# v1.6.8
 - [codezomb](https://github.com/kobaltz/clamby/commits?author=codezomb)  - Allow paths to be escaped #37

# v1.6.5
 - [bennacer860](https://github.com/kobaltz/clamby/commits?author=bennacer860) - Added config data dir option


# v1.6.2
 - [emilong](https://github.com/kobaltz/clamby/commits?author=emilong) - Handle nil exit status of clamav executable.

# v1.6.1
 - [broder](https://github.com/kobaltz/clamby/commits?author=broder) - Fixed issue with detecting clamdscan version when using custom config file

# v1.6.0
 - When checking version, use the executable configuration.

# v1.5.1
 - [ahukkanen](https://github.com/kobaltz/clamby/commits?author=ahukkanen) - Configurable execution paths

# v1.5.0
 - Exceptions are now raised under Clamby module - could be breaking change
 - [szajbus](https://github.com/kobaltz/clamby/commits?author=szajbus) fixed specs! and updated README
 - [broder](https://github.com/kobaltz/clamby/commits?author=broder) added path for config file to address strange clamscan situations
 - [tilsammans](https://github.com/kobaltz/clamby/commits?author=tilsammans) added queit, verbose and Command class

# v1.4.0
 - [emilong](https://github.com/kobaltz/clamby/commits/master?author=emilong) added `:error_clamscan_client_error => false` option to prevent error from missing running daemon or clamscan.

# v1.3.2
 - [emilong](https://github.com/kobaltz/clamby/commits/master?author=emilong) added `stream` option

# v1.3.1
 - [zealot128](https://github.com/kobaltz/clamby/commits/master?author=zealot128) added `silence_output` option

# v1.3.0
 - Fixed Dangerous Send on `system_command` method

# v1.2.5
 - [bess](https://github.com/kobaltz/clamby/commits/master?author=bess) added `fdpass` option

# v1.2.3
 - Fixed typo in config check `error_clamscan_missing` instead of `error_clamdscan_missing`

# v1.1.1
 - Daemonize option added
 - Refactor of logic
 - Cleanup
 - Thanks to @hderms for contributing!

# v1.1.0
 - Changed `scan()` to `safe?()`
 - Added `virus?()`
 - Added/Changed `rspec` to accomodate new/changed functionality

# v1.0.5
 - Made default virus detection not throw a warning
 - If scanning a file that doesn't exist, `scan(path)` will return nil.
 - If scanning a file where `clamscan` doesn't exist, `scan(path)` will return nil.
 - Added test for nil result on scanning a file that doesn't exist

# v1.0.4
 - Added tests. This WILL download a file with a virus signature. It is a safe file, but is used for the purposes of testing the detection of a virus. Regardless, use caution when running rspec as this could be potentially harmful (doubtful, but be warned).

```ruby
.ClamAV 0.98.1/18563/Sun Mar  9 17:39:31 2014
.FILE NOT FOUND on 2014-03-10 21:35:44 -0400: BAD_FILE.md
.ClamAV 0.98.1/18563/Sun Mar  9 17:39:31 2014
README.md: OK
.--2014-03-10 21:35:50--  http://www.eicar.org/download/eicar.com
Resolving www.eicar.org... 188.40.238.250
Connecting to www.eicar.org|188.40.238.250|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 68 [application/octet-stream]
Saving to: 'eicar.com'

100%[=================>] 68          --.-K/s   in 0s

2014-03-10 21:35:50 (13.0 MB/s) - 'eicar.com' saved [68/68]

ClamAV 0.98.1/18563/Sun Mar  9 17:39:31 2014
eicar.com: Eicar-Test-Signature FOUND
ClamAV 0.98.1/18563/Sun Mar  9 17:39:31 2014
eicar.com: Eicar-Test-Signature FOUND
VIRUS DETECTED on 2014-03-10 21:36:02 -0400: eicar.com
.

Finished in 17.79 seconds
5 examples, 0 failures
````

 - Changed `scanner_exists?` method to check `clamscan -V` for version instead of just `clamscan` which was causing a virus scan on the local folder. This ended up throwing false checks since I had a virus test file in the root of the directory.

 # v1.0.3
  - Added exceptions
  - New configuration options

```ruby
Clamby.configure({
   :check => false,
   :error_clamscan_missing => false,
   :error_file_missing => false,
   :error_file_virus => false
})

```
