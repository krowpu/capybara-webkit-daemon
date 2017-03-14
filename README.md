Capybara::Webkit::Daemon
========================

Long-living Capybara Webkit server process which does not leak memory
when used in Sidekiq workers. The daemon is listening on a specific TCP
port, runs `webkit_server` process for each connection and kills it when
connection is closed or aborted. Can be used for web scraping when
Capybara Webkit causes `Errno::EMFILE: Too many open files` error.
You ever can run it on machine different from where your worker is running.
However in this case some features may not work (screenshots, for example).



Qt Dependency
-------------

capybara-webkit depends on a WebKit implementation from Qt, a cross-platform
development toolkit. You'll need to download the Qt libraries to build and
install the gem. You can find instructions for downloading and installing QT on
the
[capybara-webkit wiki](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit).
capybara-webkit requires Qt version 4.8 or greater.

### TL;DR if you're on Ubuntu Xenial Xerus (16.04) LTS

```
sudo apt-get update
sudo apt-get install qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x
```



Xvfb
----

On Linux platforms, capybara-webkit requires an X server to run,
although it doesn't create any visible windows. Xvfb works fine for this.

### Easy way for Ubuntu Xenial Xerus (16.04) LTS

Install Xvfb:

```
sudo apt-get update
sudo apt-get install xvfb
```

Create user for the service:

```
sudo useradd --no-create-home --user-group xvfb
sudo reboot
```

Create file `/etc/init.d/xvfb` with the following content:

```
#!/bin/sh
# kFreeBSD do not accept scripts as interpreters, using #!/bin/sh and sourcing.
if [ true != "$INIT_D_SCRIPT_SOURCED" ]; then
  set "$0" "$@"; INIT_D_SCRIPT_SOURCED=true . /lib/init/init-d-script
fi
### BEGIN INIT INFO
# Provides:          xvfb
# Required-Start:    $remote_fs
# Required-Stop:     $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Xvfb - virtual framebuffer X server
# Description:       Xvfb is an X server that can run on machines
#                    with no display hardware and no physical input devices.
#                    It emulates a dumb framebuffer using virtual memory.
### END INIT INFO

DISPLAY=':1'

# Read configuration variable file if it is present
[ -r /etc/default/xvfb ] && . /etc/default/xvfb

NAME='xvfb'
DESC='Xvfb (virtual framebuffer X server)'
DAEMON='/usr/bin/Xvfb'
DAEMON_ARGS="$DISPLAY -screen 0 1024x768x16"
START_ARGS="--background --make-pidfile ${CHUID:+"--chuid $CHUID"}"
STOP_ARGS='--retry KILL/5'
```

Change file permissions:

```
sudo chmod 755 /etc/init.d/xvfb
```

Install service:

```
sudo update-rc.d xvfb defaults
sudo update-rc.d xvfb enable
```

By default display `:1` is used. You can set other value in `/etc/default/xvfb`.
Also set variable `CHIUD` to `xvfb:xvfb`.

```
DISPLAY=':99'
CHUID='xvfb:xvfb'
```

Don't forget to start service:

```
sudo service xvfb start
```



Installation
------------

Add the gem to your Gemfile:

```ruby
gem 'capybara-webkit-daemon', github: 'krowpu/capybara-webkit-daemon'
```

Register new Capybara driver in `config/initializers/capybara_webkit_daemon.rb`:

```ruby
Capybara.register_driver :webkit_daemon do |app|
  Capybara::Webkit::Daemon::Client::Driver.new(
    app,
    Capybara::Webkit::Configuration.to_hash.merge(
      server: Capybara::Webkit::Daemon::Client::Server.new(
        host: ENV['CAPYBARA_WEBKIT_DAEMON_HOST'],
        port: ENV['CAPYBARA_WEBKIT_DAEMON_PORT'].to_i,
      ),
    ),
  )
end
```



Usage
-----

Create Capybara session with the following code:

```ruby
session = Capybara::Session.new :webkit_daemon
```
