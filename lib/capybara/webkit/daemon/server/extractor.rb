# frozen_string_literal: true

require 'capybara/webkit/daemon/common'
require 'capybara/webkit/daemon/server/wrapper'

module Capybara
  module Webkit
    module Daemon
      module Server
        ##
        # Extracts high-level packages from wrapped text protocol.
        #
        class Extractor < Wrapper
          STATES = %i(raw header msg binary_msg).freeze

          attr_reader :state

          def initialize(*)
            super

            self.state = :raw

            @header  = nil
            @message = nil
            @size    = nil
          end

        private

          def message(s); end

          def scan(s)
            start = 0

            s.chars.each_index do |i|
              next binary_chr s, start, i if state == :binary_msg
              start = i + 1 if control_chr s, start, i
            end

            breaks s[start..-1]
          end

          def binary_chr(s, start, i)
            @size -= 1

            return unless @size.negative?

            raise unless s[i] == Common::END_CHR
            scan_msg_end s[start...i]
          end

          def control_chr(s, start, i)
            case s[i]
            when Common::HEADER_CHR then scan_header_start s[start...i]
            when Common::START_CHR  then scan_msg_start s[start...i]
            when Common::END_CHR    then scan_msg_end s[start...i]
            else
              return false
            end

            true
          end

          def scan_header_start(s)
            raise unless state == :raw
            header_starts s
          end

          def scan_msg_start(s)
            raise unless state == :raw || state == :header

            if state == :raw
              msg_starts s
            elsif state == :header
              binary_msg_starts s
            end
          end

          def scan_msg_end(s)
            raise unless state == :msg || state == :binary_msg
            msg_ends s
          end

          def header_starts(s)
            raw s unless s.empty?

            self.state = :header
            @header = ''
          end

          def msg_starts(s)
            raw s unless s.empty?

            self.state = :msg
            @message = ''
          end

          def binary_msg_starts(s)
            raw s unless s.empty?

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
            when :msg, :binary_msg
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
