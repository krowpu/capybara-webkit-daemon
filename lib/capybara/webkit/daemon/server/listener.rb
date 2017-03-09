# frozen_string_literal: true

require 'set'
require 'socket'
require 'thread'

require 'capybara/webkit/daemon/server/connection'
require 'capybara/webkit/daemon/server/link'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Listener
          LISTEN_TIMEOUT = 1

          attr_reader :logger, :port

          private :logger

          attr_reader :accepting_new_connections

          def initialize(logger:, port:)
            @logger = logger
            @port = port&.freeze

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

          def handle(client_socket)
            logger.debug "New connection from #{client_socket.peeraddr.inspect}"

            connection = Connection.new

            link = new_link socket1: connection.socket, socket2: client_socket
            link.start
          rescue => e
            logger.error e
          ensure
            delete_link link
            connection.close
            logger.debug "Connection closed #{client_socket.peeraddr.inspect}"
          end

          def server_sockets
            @server_sockets ||= Socket.tcp_server_sockets(port).map do |socket|
              socket.autoclose = false
              tcp_server = TCPServer.for_fd socket.fileno
              socket.close
              tcp_server
            end.freeze
          end

          def new_link(socket1:, socket2:)
            link = Link.new socket1: socket1, socket2: socket2, logger: logger

            @mutex.synchronize do
              @links << link
            end

            link
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
