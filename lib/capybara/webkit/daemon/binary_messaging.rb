# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      module BinaryMessaging
        HEADER_CHR = "\x01"
        START_CHR  = "\x02"
        END_CHR    = "\x03"
      end
    end
  end
end
