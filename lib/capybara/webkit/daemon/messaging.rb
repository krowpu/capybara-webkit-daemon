# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      module Messaging
        HEADER_CHR = "\x01"
        START_CHR  = "\x02"
        END_CHR    = "\x03"

        BINARY_MSG_RE = /#{HEADER_CHR}|#{START_CHR}|#{END_CHR}/
      end
    end
  end
end
