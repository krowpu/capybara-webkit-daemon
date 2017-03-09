# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      module Server
        class Link
          attr_reader :logger
          private     :logger

          TIMEOUT = 1
          BLOCK_SIZE = 2**14

          def initialize(socket1:, socket2:, logger:)
            @logger = logger

            @socket1 = socket1
            @socket2 = socket2
          end

          def start
            logger.debug "Linking sockets #{@socket1.to_i} and #{@socket2.to_i}"

            thread1 = Thread.start do
              transfer @socket2, @socket1 until @terminating
            end

            thread2 = Thread.start do
              transfer @socket1, @socket2 until @terminating
            end

          ensure
            thread1&.join
            thread2&.join
          end

          def terminate!
            @terminating = true
          end

        private

          def transfer(from, to)
            data = from.read_nonblock BLOCK_SIZE
            to.write data unless data.empty?
          rescue IO::WaitReadable
            IO.select [from], nil, nil, TIMEOUT
          rescue EOFError
            @terminating = true
          end
        end
      end
    end
  end
end
