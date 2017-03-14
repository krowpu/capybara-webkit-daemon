# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      module Common
        DEFAULT_PORT = 20_885

        START_CHR = "\x02"
        END_CHR   = "\x03"
      end
    end
  end
end
