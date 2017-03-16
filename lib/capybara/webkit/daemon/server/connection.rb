# frozen_string_literal: true

module Capybara; end

require 'capybara/webkit/connection'

require 'capybara/webkit/daemon/server/server'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Connection < Capybara::Webkit::Connection
          attr_reader :configuration

          attr_reader :socket

          def initialize(configuration:)
            @configuration = configuration

            super server: server

            @active = true
          end

          def active?
            @active
          end

          def close
            close_mutex.synchronize do
              safe_close
            end
          end

          def server
            @server ||= Capybara::Webkit::Daemon::Server::Server.new configuration: configuration
          end

        private

          def close_mutex
            @close_mutex ||= Mutex.new
          end

          def safe_close
            @active = false
          end
        end
      end
    end
  end
end
