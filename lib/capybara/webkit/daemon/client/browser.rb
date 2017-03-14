# frozen_string_literal: true

require 'capybara'
require 'capybara/webkit/browser'

require 'capybara/webkit/daemon/common'

module Capybara
  module Webkit
    module Daemon
      module Client
        class Browser < Capybara::Webkit::Browser
        private

          def message(s)
            @connection.print "#{Common::START_CHR}#{s}#{Common::END_CHR}"
          end

          def message_binary(s)
            @connaction.print "#{Common::HEADER_CHR}#{s.length}#{Common::START_CHR}#{s}#{Common::END_CHR}"
          end
        end
      end
    end
  end
end
