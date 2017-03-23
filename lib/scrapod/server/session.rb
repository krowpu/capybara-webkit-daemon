# frozen_string_literal: true

require 'scrapod/server/browser'
require 'capybara/webkit/daemon/server/link'
require 'scrapod/redis/session'

module Scrapod
  module Server
    class Session
      MAX_DURATION_CHECK_INTERVAL = 10 # seconds

      attr_reader :client
      attr_reader :configuration, :redis
      attr_reader :started_at
      attr_reader :browser, :link

      def initialize(client, configuration:, redis: nil)
        @client = client
        @configuration = configuration
        @redis = redis

        @started_at = Time.now.freeze

        set_browser
        set_link

        @redis_session = Redis::Session.create self.redis.conn, started_at: started_at if self.redis

        @active = true

        close_if_time_exceeded
      end

      def active?
        @active
      end

      def duration
        return @duration if @duration
        Time.now - started_at
      end

      def close
        close_mutex.synchronize do
          return unless active?

          @active = false

          @redis_session&.destroy

          @duration = duration

          close_link
          close_client
          close_browser
        end
      end

      def close_if_time_exceeded
        @close_if_time_exceeded ||= Thread.start do
          sleep MAX_DURATION_CHECK_INTERVAL while active? && duration <= max_duration
          close
        end
      end

      def max_duration
        @max_duration ||= configuration.to_h[:max_session_duration]
      end

    private

      def close_mutex
        @close_mutex ||= Mutex.new
      end

      def close_client
        @client = nil
      end

      def set_browser
        @browser = Scrapod::Server::Browser.new configuration: configuration
      end

      def close_browser
        browser.close
        @browser = nil
      end

      def set_link
        @link = Capybara::Webkit::Daemon::Server::Link.new client, browser
      end

      def close_link
        @link = nil
      end
    end
  end
end
