# frozen_string_literal: true

require 'capybara/webkit/daemon/server/extractor'
require 'capybara/webkit/daemon/server/inserter'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Link
          attr_reader :logger
          private     :logger

          attr_reader :extractor, :inserter

          def initialize(client:, server:, logger:)
            @logger = logger

            @client = client
            @server = server

            @extractor = Extractor.new source: client, destination: server
            @inserter = Inserter.new source: server, destination: client
          end

          def start
            logger.debug "Linking client #{@client.to_i} and server #{@server.to_i}"

            thread1 = Thread.start do
              begin
                extractor.round until @terminating
              rescue EOFError
                @terminating = true
              end
            end

            thread2 = Thread.start do
              begin
                inserter.round until @terminating
              rescue EOFError
                @terminating = true
              end
            end

          ensure
            thread1&.join
            thread2&.join
          end

          def terminate!
            @terminating = true
          end
        end
      end
    end
  end
end
