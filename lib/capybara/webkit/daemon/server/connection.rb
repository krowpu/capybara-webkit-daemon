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
          attr_reader :server
          attr_reader :socket

          def initialize(configuration:)
            @socket_class = TCPSocket

            @configuration = configuration

            set_server
            connect

            @active = true
          end

          def active?
            @active
          end

          def close
            close_mutex.synchronize do
              raise 'connection already closed' unless active?
              safe_close
            end
          end

        private

          def close_mutex
            @close_mutex ||= Mutex.new
          end

          def safe_close
            @active = false

            close_socket
            close_server
          end

          def set_server
            @server = Capybara::Webkit::Daemon::Server::Server.new configuration: configuration
          end

          def close_server
            server.close
            @server = nil
          end

          def close_socket
            socket.close
            @socket = nil
          end
        end
      end
    end
  end
end
