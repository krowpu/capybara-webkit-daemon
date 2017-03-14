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
            self.source = source
            self.destination = destination

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
            start = 0

            s.each_char.each_with_index do |c, i|
              case c
              when "\x02"
                start = scan_msg_start s, start, i
              when "\x03"
                start = scan_msg_end s, start, i
              end
            end

            breaks s[start..-1]
          end

          def scan_msg_start(s, start, i)
            msg_starts s[start...i]
            i + 1
          end

          def scan_msg_end(s, start, i)
            msg_ends s[start...i]
            i + 1
          end

          def msg_starts(s)
            raise unless @message.nil?

            raw s unless s.empty?
            @message = ''
          end

          def msg_ends(s)
            raise if @message.nil?

            got @message + s
            @message = nil
          end

          def breaks(s)
            return if s.empty?

            if @message.nil?
              raw s
            else
              @message += s
            end
          end

          def raw(s)
            destination.write s unless s.empty?
          end

          def got(s); end

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
