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
          attr_reader :connection

          def initialize(configuration:)
            @configuration = configuration

            set_connection

            @active = true
          end

          def active?
            @active
          end

          def close
            raise 'browser already closed' unless active?
            safe_close
          end

        private

          def safe_close
            @active = false

            close_connection
          end

          def set_connection
            @connection = Connection.new configuration: configuration
          end

          def close_connection
            connection.close
            @connection = nil
          end
        end
      end
    end
  end
end
