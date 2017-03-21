# frozen_string_literal: true

module Capybara; end

require 'capybara/webkit/connection'

require 'scrapod/server/server'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Connection < Capybara::Webkit::Connection
          attr_reader :configuration
          attr_reader :server
          attr_reader :socket

          private :port, :pid

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
              return unless active?

              @active = false

              close_socket
              close_server
            end
          end

        private

          def close_mutex
            @close_mutex ||= Mutex.new
          end

          def set_server
            @server = Scrapod::Server::Server.new configuration: configuration
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
