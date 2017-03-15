# frozen_string_literal: true

require 'capybara/webkit/daemon/inserter'
require 'capybara/webkit/daemon/server/wrapper'

module Capybara
  module Webkit
    module Daemon
      module Server
        ##
        # Inserts high-level packages to wrapped text protocol.
        #
        class Inserter < Wrapper
          def message(s)
            raw inserter.message s
          end

          def message_binary(s)
            raw inserter.binary_message s
          end

        private

          def inserter
            @inserter ||= Daemon::Inserter.new
          end
        end
      end
    end
  end
end
