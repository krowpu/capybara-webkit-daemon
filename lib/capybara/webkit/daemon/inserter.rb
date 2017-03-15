# frozen_string_literal: true

require 'capybara/webkit/daemon/common'

module Capybara
  module Webkit
    module Daemon
      class Inserter
        BINARY_MSG_RE = /#{Common::HEADER_CHR}|#{Common::START_CHR}|#{Common::END_CHR}/

        def call(s)
          if s =~ BINARY_MSG_RE
            binary_message s
          else
            message s
          end
        end

        def message(s)
          "#{Common::START_CHR}#{s}#{Common::END_CHR}"
        end

        def binary_message(s)
          "#{Common::HEADER_CHR}#{s.length}#{Common::START_CHR}#{s}#{Common::END_CHR}"
        end
      end
    end
  end
end
