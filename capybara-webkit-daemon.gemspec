# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path '../lib', __FILE__

$LOAD_PATH.unshift lib unless $LOAD_PATH.include? lib

require 'capybara/webkit/daemon/version'

Gem::Specification.new do |spec|
  spec.name     = 'capybara-webkit-daemon'
  spec.version  = Capybara::Webkit::Daemon::Version::VERSION
  spec.summary  = 'Long-living Capybara Webkit process for web scraping.'
  spec.homepage = 'https://github.com/krowpu/capybara-webkit-daemon'
  spec.license  = 'MIT'

  spec.authors = ['krowpu']
  spec.email   = ['krowpu@tightmail.com']

  spec.description = <<-END.gsub(/^\s*/, '')
    Long-living Capybara Webkit server process which does not leak memory
    when used in Sidekiq workers. The daemon is listening on a specific TCP
    port, runs `webkit_server` process for each connection and kills it when
    connection is closed or aborted. Can we used for web scraping when
    Capybara Webkit causes `Errno::EMFILE: Too many open files` error.
    You ever can run it on machine different from where your worker is running.
    However in this case some features may not work (screenshots, for example).
  END

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match %r{^(test|spec|features)/}
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename f }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'pry',     '~> 0.10'
  spec.add_development_dependency 'rubocop', '~> 0.47'
end
