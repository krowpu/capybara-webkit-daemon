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

### TL;DR if you're on Ubuntu Trusty (14.04)

```
sudo apt-get update
sudo apt-get install qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x
```

Xvfb
----

On Linux platforms, capybara-webkit requires an X server to run,
although it doesn't create any visible windows. Xvfb works fine for this.
You can setup Xvfb yourself and set a DISPLAY variable or use the xvfb-run
utility as follows:

```
xvfb-run -a bundle exec capybara-webkit-daemon
```

This automatically sets up a virtual X server on a free server number.

Installation
------------

Add the gem to your Gemfile:

```ruby
gem 'capybara-webkit-daemon`, github: 'krowpu/capybara-webkit-daemon'
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
