# frozen_string_literal: true

require 'capybara/webkit/daemon/common'
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
            raw "#{Common::START_CHR}#{s}#{Common::END_CHR}"
          end
        end
      end
    end
  end
end
