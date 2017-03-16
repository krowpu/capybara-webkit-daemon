# frozen_string_literal: true

require 'capybara/webkit/daemon/server/browser'
require 'capybara/webkit/daemon/server/link'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Session
          MAX_DURATION = 5 * 60 # 5 minutes
          MAX_DURATION_CHECK_INTERVAL = 10 # seconds

          attr_reader :client
          attr_reader :configuration
          attr_reader :started_at
          attr_reader :browser, :link

          def initialize(client, configuration:)
            @client = client
            @configuration = configuration

            @started_at = Time.now.freeze

            set_browser
            set_link

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
              safe_close
            end
          end

          def close_if_time_exceeded
            @close_if_time_exceeded ||= Thread.start do
              sleep MAX_DURATION_CHECK_INTERVAL while active? && duration <= MAX_DURATION

              close_mutex.synchronize do
                safe_close
              end
            end
          end

        private

          def close_mutex
            @close_mutex ||= Mutex.new
          end

          def safe_close
            return unless active?

            @active = false

            @duration = duration

            close_link
            close_client
            close_browser
          end

          def close_client
            @client = nil
          end

          def set_browser
            @browser = Browser.new configuration: configuration
          end

          def close_browser
            browser.close
            @browser = nil
          end

          def set_link
            @link = Link.new client, browser
          end

          def close_link
            @link = nil
          end
        end
      end
    end
  end
end
