# frozen_string_literal: true

require 'redis'

require 'securerandom'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Redis
          attr_reader :url

          def initialize(url)
            self.url = url
            set_conn
          end

          def version
            conn.info('server')['redis_version']
          end

          def add_session
            id = SecureRandom.uuid
            conn.sadd 'sessions', id
            id
          end

          def delete_session(id)
            conn.srem 'sessions', id
          end

        private

          attr_reader :conn

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
