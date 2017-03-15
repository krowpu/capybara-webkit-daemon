# frozen_string_literal: true

require 'capybara/webkit/daemon/server/browser'
require 'capybara/webkit/daemon/server/link'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Session
          attr_reader :client
          attr_reader :configuration
          attr_reader :started_at

          def initialize(client, configuration:)
            @client = client
            @configuration = configuration

            @started_at = Time.now.freeze

            browser

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
        end
      end
    end
  end
end
