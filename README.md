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

Create user for the service:

```
sudo useradd --no-create-home --user-group xvfb
sudo reboot
```

Install Xvfb init.d script:

```
sudo wget https://gist.githubusercontent.com/krowpu/e5b388e4640c679bf495769720609783/raw/94398b7211eb46649d0f73dc60a59b9be6fb6e14/xvfb.sh -O /etc/init.d/xvfb
sudo chmod 755 /etc/init.d/xvfb
sudo update-rc.d xvfb defaults
sudo update-rc.d xvfb enable
```

By default display `:1` is used. You can set other value in `/etc/default/xvfb`.
Also set variable `CHIUD` to `xvfb:xvfb`.

```
DISPLAY=':99'
CHUID='ubuntu:ubuntu'
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
  Capybara::Webkit::Driver.new(
    app,
    Capybara::Webkit::Configuration.to_hash.merge(
      server: Capybara::Webkit::Daemon::Client::Server.new,
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
