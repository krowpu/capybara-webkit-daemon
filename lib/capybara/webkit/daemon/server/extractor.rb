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

          def extracted(s); end

          def scan(s)
            start = 0

            s.each_char.each_with_index do |c, i|
              if state == :binary_msg
                @size -= 1

                if @size.negative?
                  raise unless c == Common::END_CHR
                  scan_msg_end s, start, i
                end

                next
              end

              new_start = control_chr s, start, i
              start = new_start if new_start
            end

            breaks s[start..-1]
          end

          def control_chr(s, start, i)
            case s[i]
            when Common::HEADER_CHR
              scan_header_start s, start, i
            when Common::START_CHR
              scan_msg_start s, start, i
            when Common::END_CHR
              scan_msg_end s, start, i
            end
          end

          def scan_header_start(s, start, i)
            header_starts s[start...i]
            i + 1
          end

          def scan_msg_start(s, start, i)
            msg_starts s[start...i]
            i + 1
          end

          def scan_msg_end(s, start, i)
            msg_ends s[start...i]
            i + 1
          end

          def header_starts(s)
            raise unless state == :raw

            raw s unless s.empty?

            self.state = :header
            @header = ''
          end

          def msg_starts(s)
            raise unless state == :raw || state == :header

            raw s unless s.empty?

            if state == :raw
              self.state = :msg
            elsif state == :header
              self.state = :binary_msg
              header = @header + s
              @header = nil
              raise unless header =~ /\A\d+\z/
              @size = header.to_i
            end

            @message = ''
          end

          def msg_ends(s)
            raise unless state == :msg || state == :binary_msg

            extracted @message + s

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

        private

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
