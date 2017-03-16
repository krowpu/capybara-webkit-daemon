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

          def initialize(client, configuration:)
            @client = client
            @configuration = configuration

            @started_at = Time.now.freeze

            browser

            close_if_time_exceeded

            @active = true
          end

          def active?
            @active
          end

          def duration
            return @duration if @duration
            Time.now - started_at
          end

          def close
            raise 'session already closed' unless active?

            @active = false
            @duration = duration
            browser.close
          end

          def browser
            @browser ||= Browser.new configuration: configuration
          end

          def link
            @link ||= Link.new client, browser
          end

          def close_if_time_exceeded
            @close_if_time_exceeded ||= Thread.start do
              sleep MAX_DURATION_CHECK_INTERVAL while active? && duration <= MAX_DURATION
              close if active?
            end
          end
        end
      end
    end
  end
end
