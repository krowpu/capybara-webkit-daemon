# frozen_string_literal: true

require 'capybara/webkit/daemon/messaging'

module Capybara
  module Webkit
    module Daemon
      module Messaging
        ##
        # Inserts high-level packages to wrapped text protocol.
        #
        class Inserter
          include Messaging

          def initialize(&block)
            @block = block
          end

          def call(s)
            if s =~ BINARY_MSG_RE
              binary_message s
            else
              message s
            end
          end

          def message(s)
            @block&.("#{START_CHR}#{s}#{END_CHR}")
          end

          def binary_message(s)
            @block&.("#{HEADER_CHR}#{s.length}#{START_CHR}#{s}#{END_CHR}")
          end
        end
      end
    end
  end
end
