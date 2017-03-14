# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      module Server
        ##
        # Wraps single direction data transfer of an arbitrary
        # protocol. Can extract/insert high-level packages
        # from/to the stream.
        #
        class Wrapper
          DEFAULT_TIMEOUT = 1
          DEFAULT_BLOCK_SIZE = 2**14

          attr_reader :source, :destination
          attr_reader :timeout, :block_size

          def initialize(source:, destination:)
            self.source = source
            self.destination = destination

            self.timeout = DEFAULT_TIMEOUT
            self.block_size = DEFAULT_BLOCK_SIZE
          end

          def round
            data = source.read_nonblock block_size
            destination.write data unless data.empty?
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

          def source=(io)
            raise TypeError, "expected source to be an #{IO}" unless io.is_a? IO
            @source = io
          end

          def destination=(io)
            raise TypeError, "expected destination to be an #{IO}" unless io.is_a? IO
            @destination = io
          end
        end
      end
    end
  end
end
