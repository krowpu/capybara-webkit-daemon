# frozen_string_literal: true

require 'capybara/webkit/connection'

module Capybara
  module Webkit
    module Daemon
      module Client
        class Connection < Capybara::Webkit::Connection
          def host
            @server.host
          end

        private

          def attempt_connect
            @socket = @socket_class.open host, port

            if defined? Socket::TCP_NODELAY
              @socket.setsockopt Socket::IPPROTO_TCP, Socket::TCP_NODELAY, true
            end

          rescue Errno::ECONNREFUSED # rubocop:disable Lint/HandleException
          end
        end
      end
    end
  end
end
