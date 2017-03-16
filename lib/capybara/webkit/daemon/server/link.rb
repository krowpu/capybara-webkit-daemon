# frozen_string_literal: true

require 'capybara/webkit/daemon/server/client_to_server_wrapper'
require 'capybara/webkit/daemon/server/server_to_client_wrapper'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Link
          attr_reader :client, :browser

          def initialize(client, browser)
            @client = client
            @browser = browser
          end

          def client_to_server_wrapper
            @client_to_server_wrapper ||= ClientToServerWrapper.new(
              source:      client.socket,
              destination: browser.connection.socket,
            )
          end

          def server_to_client_wrapper
            @server_to_client_wrapper ||= ServerToClientWrapper.new(
              source:      browser.connection.socket,
              destination: client.socket,
            )
          end

          def start
            client_to_server_thread
            server_to_client_thread
          ensure
            client_to_server_thread&.join
            server_to_client_thread&.join
          end

          def terminate!
            @terminating = true
          end

        private

          def client_to_server_thread
            @client_to_server_thread ||= Thread.start do
              begin
                client_to_server_wrapper.round until @terminating
              rescue IOError
                @terminating = true
              end
            end
          end

          def server_to_client_thread
            @server_to_client_thread ||= Thread.start do
              begin
                server_to_client_wrapper.round until @terminating
              rescue IOError
                @terminating = true
              end
            end
          end
        end
      end
    end
  end
end
