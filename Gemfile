# frozen_string_literal: true

source 'https://rubygems.org'

git_source :krowpu do |repo_name|
  "https://github.com/krowpu/#{repo_name}.git"
end

# Specify your gem's dependencies in scrapod-server.gemspec
gemspec

# Scrapod data records in Redis.
gem 'scrapod-redis', krowpu: 'scrapod-redis'
