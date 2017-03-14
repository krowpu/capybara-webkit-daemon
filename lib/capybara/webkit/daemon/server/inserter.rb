# frozen_string_literal: true

require 'capybara/webkit/daemon/server/wrapper'

module Capybara
  module Webkit
    module Daemon
      module Server
        ##
        # Inserts high-level packages to wrapped text protocol.
        #
        class Inserter < Wrapper
          def insert(s)
            raw "\x02#{s}\x03"
          end
        end
      end
    end
  end
end
