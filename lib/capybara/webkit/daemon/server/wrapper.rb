# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      module Server
        ##
        # Wraps single direction data transfer of an arbitrary text protocol.
        #
        class Wrapper
          DEFAULT_TIMEOUT = 1
          DEFAULT_BLOCK_SIZE = 2**14

          attr_reader :source, :destination
          attr_reader :timeout, :block_size

          def initialize(source:, destination:)
            @source      = source
            @destination = destination

            self.timeout = DEFAULT_TIMEOUT
            self.block_size = DEFAULT_BLOCK_SIZE
          end

          def round
            scan source.read_nonblock block_size
          rescue IO::WaitReadable
            IO.select [source], nil, nil, timeout
          end

          def timeout=(secs)
            return @timeout = nil if secs.nil?

            unless secs.is_a?(Integer) || secs.is_a?(Float)
              raise TypeError, "expected timeout to be a #{Integer}, #{Float}, #{NilClass}"
            end

            raise ArgumentError, 'expected timeout to be greater than zero' unless secs.positive?

            @timeout = secs
          end

          def block_size=(bytes)
            raise TypeError, "expected block size to be an #{Integer}" unless bytes.is_a? Integer
            raise ArugmentError, 'expected block size to be greater than zero' unless bytes.positive?
            @block_size = bytes
          end

        private

          def scan(s)
            raw s
          end

          def raw(s)
            write s
          end

          def write(s)
            destination.write s unless s.empty?
          end
        end
      end
    end
  end
end
