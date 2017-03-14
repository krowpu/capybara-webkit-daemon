# frozen_string_literal: true

require 'set'
require 'socket'
require 'thread'

require 'capybara/webkit/daemon/server/client'
require 'capybara/webkit/daemon/server/session'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Listener
          LISTEN_TIMEOUT = 1

          attr_reader :configuration, :logger

          private :logger

          attr_reader :accepting_new_connections

          def initialize(configuration:, logger:)
            @configuration = configuration
            @logger = logger

            @mutex = Mutex.new
            @links = Set.new
          end

          def start
            @accepting_new_connections = true

            threads = []

            server_sockets.each do |server_socket|
              threads << Thread.start do
                listen server_socket
              end
            end

          ensure
            threads&.each(&:join)
          end

          def stop_accepting_new_connections!
            return unless @accepting_new_connections
            @accepting_new_connections = false
            logger.info 'Stopped accepting new connections'
          end

          def terminate!
            stop_accepting_new_connections!
            logger.info 'Terminating connections...'
            terminate_links
          end

          def binding
            @binding ||= configuration.to_h[:binding]
          end

          def port
            @port ||= configuration.to_h[:port]
          end

        private

          def listen(server_socket)
            logger.info "Started listening on #{server_socket.addr.inspect}"

            threads = []

            while accepting_new_connections
              thread = accept server_socket
              threads << thread if thread
            end

          ensure
            threads&.each(&:join)
          end

          def accept(server_socket)
            Thread.start server_socket.accept_nonblock do |client_socket|
              handle client_socket
            end
          rescue IO::WaitReadable
            IO.select [server_socket], nil, nil, LISTEN_TIMEOUT
            nil
          end

          def handle(client_socket) # rubocop:disable Metrics/AbcSize
            logger.debug "New connection from #{client_socket.peeraddr.inspect}"

            client = Client.new client_socket
            session = Session.new client, configuration: configuration

            add_link session.link
            session.link.start

          rescue => e
            logger.error e

          ensure
            delete_link session.link
            session.close

            logger.debug "Connection closed #{client_socket.peeraddr.inspect}"
          end

          def server_sockets
            @server_sockets ||= Socket.tcp_server_sockets(binding, port).map do |socket|
              socket.autoclose = false
              tcp_server = TCPServer.for_fd socket.fileno
              socket.close
              tcp_server
            end.freeze
          end

          def add_link(link)
            @mutex.synchronize do
              @links << link
            end
          end

          def delete_link(link)
            @mutex.synchronize do
              @links.delete link
            end
          end

          def terminate_links
            @mutex.synchronize do
              @links.each(&:terminate!)
            end
          end
        end
      end
    end
  end
end
