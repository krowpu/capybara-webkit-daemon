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

          def initialize(*)
            super

            self.state = :raw

            @message = nil
          end

        private

          def extracted(s); end

          def scan(s)
            start = 0

            s.each_char.each_with_index do |c, i|
              case c
              when Common::START_CHR
                start = scan_msg_start s, start, i
              when Common::END_CHR
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

        private

          def state=(sym)
            unless STATES.include? sym
              raise(
                ArgumentError,
                "invalid state #{sym.inspect}, possible are #{STATES.map(&:inspect).join(', ')}"
              )
            end
          end
        end
      end
    end
  end
end
