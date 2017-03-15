# frozen_string_literal: true

require 'capybara/webkit/daemon/server/wrapper'
require 'capybara/webkit/daemon/messaging/inserter'
require 'capybara/webkit/daemon/binary_messaging/inserter'

module Capybara
  module Webkit
    module Daemon
      module Server
        class ServerToClientWrapper < Wrapper
          def message(s)
            inserter.call s
          end

          def message_binary(s)
            binary_inserter.call s
          end

        private

          def inserter
            @inserter ||= Messaging::Inserter.new do |s|
              raw s
            end
          end

          def binary_inserter
            @inserter ||= BinaryMessaging::Inserter.new do |s|
              raw s
            end
          end
        end
      end
    end
  end
end
