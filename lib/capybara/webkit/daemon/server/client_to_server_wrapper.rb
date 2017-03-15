# frozen_string_literal: true

require 'capybara/webkit/daemon/server/wrapper'
require 'capybara/webkit/daemon/server/capybara_webkit_protocol_parser'
require 'capybara/webkit/daemon/messaging/extractor'

module Capybara
  module Webkit
    module Daemon
      module Server
        class ClientToServerWrapper < Wrapper
        private

          def scan(s)
            raw capybara_webkit_protocol_parser.call extractor.call s
          end

          def capybara_webkit_protocol_parser
            @capybara_webkit_protocol_parser ||= CapybaraWebkitProtocolParser.new
          end

          def extractor
            @extractor ||= Messaging::Extractor.new do |msg|
              message msg
            end
          end

          def message(s); end

          def render(path, width, height); end
        end
      end
    end
  end
end
