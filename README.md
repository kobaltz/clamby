![Clamby Logo](https://raw.github.com/kobaltz/clamby/master/clamby_logo.png)

[![GemVersion](https://badge.fury.io/rb/clamby.png)](https://badge.fury.io/rb/clamby.png)
[![Ruby CI](https://github.com/kobaltz/clamby/actions/workflows/ruby-ci.yml/badge.svg)](https://github.com/kobaltz/clamby/actions/workflows/ruby-ci.yml)

This gem depends on the [clamscan](http://www.clamav.net/) and `freshclam` daemons to be installed already.

If you have a file upload on your site and you do not scan the files for viruses then you not only compromise your software, but also the users of the software and their files. This gem's function is to simply scan a given file.

# Usage

[Drifting Ruby Screencast](https://www.driftingruby.com/episodes/antivirus-uploads-with-clamby?utm_source=github&utm_medium=social&utm_campaign=github)

Be sure to check the CHANGELOG as recent changes may affect functionality.

Just add `gem 'clamby'` to your `Gemfile` and run `bundle install`.

You can use two methods to scan a file for a virus:

If you use `safe?` to scan a file, it will return `true` if no viruses were found, `false` if a virus was found, and `nil` if there was a problem finding the file or if there was a problem using `clamscan`

`Clamby.safe?(path_to_file)`

If you use `virus?` to scan a file, it will return `true` if a virus was found, `false` if no virus was found, and `nil` if there was a problem finding the file or if there was a problem using `clamscan`


`Clamby.virus?(path_to_file)`

In your model with the uploader, you can add the scanner to a before method to scan the file. When a file is scanned, a successful scan will return `true`. An unsuccessful scan will return `false`. A scan may be unsuccessful for a number of reasons; `clamscan` could not be found, `clamscan` returned a virus, or the file which you were trying to scan could not be found.

```ruby
  before_create :scan_for_viruses

  private

  def scan_for_viruses
      path = self.attribute.url
      Clamby.safe?(path)
  end
```

***Updating Definitions***

I have done little testing with updating definitions online. However, there is a method that you can call `Clamby.update` which will execute `freshclam`. It is recommended that you follow the instructions below to ensure that this is done automatically on a daily/weekly basis.

***Viruses Detected***

It's good to note that Clamby will not by default delete files which had a virus. Instead, this is left to you to decide what should occur with that file. Below is an example where if a scan came back `false`, the file would be deleted.

```ruby
  before_create :scan_for_viruses

  private

  def scan_for_viruses
      path = self.attribute.path
      scan_result = Clamby.safe?(path)
      if scan_result
        return true
      else
        File.delete(path)
        return false
      end
  end
```

## with ActiveStorage

With ActiveStorage, you don't have access to the file through normal methods, so you'll have to access the file through the `attachment_changes`.

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
  before_save :scan_for_viruses

  private

  def scan_for_viruses
    return unless self.attachment_changes['avatar']

    path = self.attachment_changes['avatar'].attachable.tempfile.path
    Clamby.safe?(path)
  end
end
```

# Configuration

Configuration is rather limited right now. You can exclude the check if `clamscan` exists which will save a bunch of time for scanning your files. However, for development purposes, your machine may not have `clamscan` installed and you may wonder why it's not working properly. This is just to give you a reminder to install `clamscan` on your development machine and production machine. You can add the following to an initializer, for example `config/initializers/clamby.rb`:

```ruby
    Clamby.configure({
      :check => false,
      :daemonize => false,
      :config_file => nil,
      :error_clamscan_missing => true,
      :error_clamscan_client_error => false,
      :error_file_missing => true,
      :error_file_virus => false,
      :fdpass => false,
      :stream => false,
      :reload => false,
      :output_level => 'medium', # one of 'off', 'low', 'medium', 'high'
      :executable_path_clamscan => 'clamscan',
      :executable_path_clamdscan => 'clamdscan',
      :executable_path_freshclam => 'freshclam',
    })
```

#### Daemonize

I highly recommend using the `daemonize` set to `true`. This will allow for clamscan to remain in memory and will not have to load for each virus scan. It will save several seconds per request.

To specify a config file for clamdscan to use, you can set `config_file` with the relevant path. See [this page](https://linux.die.net/man/5/clamd.conf) for more information about the config file.

#### Error suppression

There has been added additional functionality where you can override exceptions. If you set the exceptions below to false, then there will not be a hard exception generated. Instead, it will post to your log that an error had occured. By default each one of these configuration options are set to true. You may want to set these to false in your production environment.

#### Pass file descriptor permissions to clamd

Setting the `fdpass` configuration option to `true` will pass the `--fdpass` option to clamscan. This might be useful if you are encountering permissions problems between clamscan and files being created by your application. From the clamscan man page:

`--fdpass : Pass the file descriptor permissions to clamd. This is useful if clamd is running as a different user as it is faster than streaming the file to clamd. Only available if connected to clamd via local(unix) socket.`

#### Force streaming files to clamd

Setting the `stream` configuration option will stream the file to the daemon. This may be useful for forcing streaming as a test for local development. Only works when also specifying `daemonize`. From the clamdscan man page:

`--stream : Forces file streaming to clamd. This is generally not needed as clamdscan detects automatically if streaming is required. This option only exists for debugging and testing purposes, in all other cases --fdpass is preferred.`

#### Force streaming files to clamd

Setting the `reload` configuration option to `true` will pass the `--reload` option  to the daemon. Only works when also specifying `daemonize`. From the clamdscan man page:

`--reload : Request clamd to reload virus database.`

#### Output levels

- *off*: suppress all output
- *low*: show errors, but nothing else
- *medium*: show errors and briefly what happened _(default)_
- *high*: as verbose as possible

#### Executable paths

Setting any of the executable paths makes Clamby to use those paths instead of
the defaults for the system calls. The default configuration for these should be
perfectly fine for most use cases but it may be required to configure custom
paths in case ClamAV is manually installed to a custom location.

In order to configure the paths, use the following configuration options:

- *executable_path_clamscan*: defines the executable path for the `clamscan`
  executable, defaults to `clamscan`
- *executable_path_clamdscan*: defines the executable path for the `clamdscan`
  executable, defaults to `clamdscan`
- *executable_path_freshclam*: defines the executable path for the `freshclam`
  executable, defaults to `freshclam`

# Dependencies

***Ubuntu***

`sudo apt-get install clamav clamav-daemon`

Note, `clamav-daemon` is optional but recommended. It's needed if you wish to
run ClamAV in daemon mode.

***macOS***

`brew install clamav`

***Auto Update****

To update the virus database, open a terminal and enter the following command:

`sudo freshclam`

To automate this update you can set up a cron job. I'll show how to update the virus database every day at 8:57 PM.

You need to modify the crontab for the root user.

`sudo crontab -e`

This opens the root crontab file in a text editor. Add the following line

`57 08 * * * sudo freshclam`

# Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

# LICENSE

Copyright (c) 2016 kobaltz

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

ClamAV is licensed under [GNU GPL](http://www.gnu.org/licenses/gpl.html). The ClamAV software is NOT distributed nor modified with this gem.
