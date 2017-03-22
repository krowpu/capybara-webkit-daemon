# frozen_string_literal: true

require 'redis'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Redis
          attr_reader :url, :conn

          def initialize(url)
            self.url = url
            set_conn
          end

          def version
            conn.info('server')['redis_version']
          end

        private

          def url=(value)
            raise TypeError, "expected url to be a #{String}" unless value.is_a? String
            @url = value.dup.freeze
          end

          def set_conn
            @conn = ::Redis.new url: url
            raise "can not connect to Redis at #{url.inspect}" unless conn.ping == 'PONG'
          end
        end
      end
    end
  end
end
