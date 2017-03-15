# frozen_string_literal: true

require 'capybara/webkit/daemon/binary_messaging'

module Capybara
  module Webkit
    module Daemon
      module BinaryMessaging
        ##
        # Extracts high-level binary packages from wrapped text protocol.
        #
        class Extractor
          include BinaryMessaging

          STATES = %i(raw header binary_msg).freeze

          attr_reader :state

          def initialize(&block)
            self.state = :raw

            @block = block

            @raw = ''

            @header  = nil
            @message = nil
            @size    = nil
          end

          def call(s)
            scan s
            result = @raw
            @raw = ''
            result
          end

        private

          def raw(s)
            @raw += s
          end

          def message(s)
            @block&.(s)
          end

          def scan(s)
            start = 0

            s.length.times do |i|
              if state == :binary_msg
                start = i + 1 if binary_chr s, start, i
                next
              end

              start = i + 1 if control_chr s, start, i
            end

            breaks s[start..-1]
          end

          def binary_chr(s, start, i)
            @size -= 1

            return false unless @size.negative?

            raise unless s[i] == END_CHR
            scan_msg_end s[start...i]
            true
          end

          def control_chr(s, start, i)
            case s[i]
            when HEADER_CHR then scan_header_start s[start...i]
            when START_CHR  then scan_msg_start s[start...i]
            when END_CHR    then scan_msg_end s[start...i]
            else
              false
            end
          end

          def scan_header_start(s)
            raise unless state == :raw
            header_starts s
            true
          end

          def scan_msg_start(s)
            return false unless state == :header
            binary_msg_starts s
            true
          end

          def scan_msg_end(s)
            return false unless state == :binary_msg
            msg_ends s
            true
          end

          def header_starts(s)
            raw s unless s.empty?

            self.state = :header
            @header = ''
          end

          def binary_msg_starts(s)
            self.state = :binary_msg
            header = @header + s
            @header = nil
            raise unless header =~ /\A\d+\z/
            @size = header.to_i
            @message = ''
          end

          def msg_ends(s)
            message @message + s

            self.state = :raw
            @message = nil
            @size = nil
          end

          def breaks(s)
            return if s.empty?

            case state
            when :raw
              raw s
            when :binary_msg
              @message += s
            when :header
              @header += s
            end
          end

          def state=(sym)
            unless STATES.include? sym
              raise(
                ArgumentError,
                "invalid state #{sym.inspect}, possible are #{STATES.map(&:inspect).join(', ')}",
              )
            end

            @state = sym
          end
        end
      end
    end
  end
end
