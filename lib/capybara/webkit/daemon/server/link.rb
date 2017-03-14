# frozen_string_literal: true

require 'capybara/webkit/daemon/server/extractor'
require 'capybara/webkit/daemon/server/wrapper'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Link
          attr_reader :logger
          private     :logger

          attr_reader :extractor, :wrapper2_to1

          def initialize(socket1:, socket2:, logger:)
            @logger = logger

            @socket1 = socket1
            @socket2 = socket2

            @extractor = Extractor.new source: socket1, destination: socket2
            @wrapper2_to1 = Wrapper.new source: socket2, destination: socket1
          end

          def start
            logger.debug "Linking sockets #{@socket1.to_i} and #{@socket2.to_i}"

            thread1 = Thread.start do
              begin
                extractor.round until @terminating
              rescue EOFError
                @terminating = true
              end
            end

            thread2 = Thread.start do
              begin
                wrapper2_to1.round until @terminating
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
