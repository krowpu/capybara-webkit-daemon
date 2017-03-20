# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path '../lib', __FILE__

$LOAD_PATH.unshift lib unless $LOAD_PATH.include? lib

require 'scrapod/server/version'

Gem::Specification.new do |spec|
  spec.name     = 'scrapod-server'
  spec.version  = Scrapod::Server::Version::VERSION
  spec.summary  = 'Long-living Capybara Webkit process for web scraping.'
  spec.homepage = 'https://github.com/krowpu/scrapod-server'
  spec.license  = 'MIT'

  spec.author = 'krowpu'
  spec.email  = 'krowpu@tightmail.com'

  spec.description = <<-END.split("\n").map(&:strip).join ' '
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
  spec.require_paths = %w(lib)

  spec.requirements << 'Qt WebKit'
  spec.requirements << 'Xvfb'

  spec.add_development_dependency 'bundler',   '~> 1.13'
  spec.add_development_dependency 'rake',      '~> 10.0'
  spec.add_development_dependency 'pry',       '~> 0.10'
  spec.add_development_dependency 'rubocop',   '~> 0.47'
  spec.add_development_dependency 'rspec',     '~> 3.5'
  spec.add_development_dependency 'simplecov', '~> 0.14'
  spec.add_development_dependency 'timecop',   '~> 0.8'

  spec.add_runtime_dependency 'capybara',        '2.4.4'
  spec.add_runtime_dependency 'capybara-webkit', '1.11.1'

  spec.add_runtime_dependency 'redis', '>= 4.0.0.rc1', '<= 5.0'
end
