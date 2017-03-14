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
          end

        private

          def extracted(s); end

          def scan(s)
            start = 0

            s.each_char.each_with_index do |c, i|
              case c
              when Common::HEADER_CHR
                start = scan_header_start s, start, i
              when Common::START_CHR
                start = scan_msg_start s, start, i
              when Common::END_CHR
                start = scan_msg_end s, start, i
              end
            end

            breaks s[start..-1]
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
            raise s unless state == :raw

            raw s unless s.empty?

            self.state = :msg
            @message = ''
          end

          def msg_ends(s)
            raise unless state == :msg

            extracted @message + s

            self.state = :raw
            @message = nil
          end

          def breaks(s)
            return if s.empty?

            if state == :raw
              raw s
            else
              raise "#{state.inspect}: #{s}" if @message.nil?
              @message += s
            end
          end

        private

          def state=(sym)
            unless STATES.include? sym
              raise(
                ArgumentError,
                "invalid state #{sym.inspect}, possible are #{STATES.map(&:inspect).join(', ')}"
              )
            end

            @state = sym
          end
        end
      end
    end
  end
end
