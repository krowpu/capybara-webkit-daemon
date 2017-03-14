# frozen_string_literal: true

require 'capybara/webkit/daemon/server/wrapper'

module Capybara
  module Webkit
    module Daemon
      module Server
        ##
        # Extracts high-level packages from wrapped text protocol.
        #
        class Extractor < Wrapper
          def initialize(*)
            super

            @message = nil
          end

        private

          def extracted(s); end

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

            extracted @message + s
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
        end
      end
    end
  end
end
