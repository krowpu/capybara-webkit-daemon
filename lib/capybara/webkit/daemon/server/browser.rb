# frozen_string_literal: true

require 'capybara'
require 'capybara/webkit/browser'

require 'capybara/webkit/daemon/server/connection'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Browser < Capybara::Webkit::Browser
          attr_reader :configuration

          def initialize(configuration:)
            @configuration = configuration
            connection

            @active = true
          end

          def active?
            @active
          end

          def close
            close_mutex.synchronize do
              raise 'browser already closed' unless active?
              safe_close
            end
          end

          def connection
            @connection ||= Connection.new configuration: configuration
          end

        private

          def close_mutex
            @close_mutex ||= Mutex.new
          end

          def safe_close
            @active = false

            connection.close
          end
        end
      end
    end
  end
end
