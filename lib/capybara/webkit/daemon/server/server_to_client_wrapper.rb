# frozen_string_literal: true

require 'capybara/webkit/daemon/server/wrapper'
require 'capybara/webkit/daemon/messaging/inserter'

module Capybara
  module Webkit
    module Daemon
      module Server
        class ServerToClientWrapper < Wrapper
          def message(s)
            raw inserter.message s
          end

          def message_binary(s)
            raw inserter.binary_message s
          end

        private

          def inserter
            @inserter ||= Messaging::Inserter.new
          end
        end
      end
    end
  end
end
