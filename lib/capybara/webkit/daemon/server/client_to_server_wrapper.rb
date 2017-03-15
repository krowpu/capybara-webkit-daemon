# frozen_string_literal: true

require 'capybara/webkit/daemon/server/wrapper'
require 'protocol_injector'
require 'capybara/webkit/daemon/server/capybara_webkit_protocol_parser'
require 'capybara/webkit/daemon/messaging/extractor'
require 'capybara/webkit/daemon/binary_messaging/extractor'

module Capybara
  module Webkit
    module Daemon
      module Server
        class ClientToServerWrapper < Wrapper
        private

          def scan(s)
            raw injector.(s)
          end

          def injector
            @injector ||= ProtocolInjector.new
                                          .inject(binary_extractor)
                                          .inject(extractor)
                                          .inject(capybara_webkit_protocol_parser)
          end

          def binary_extractor
            @binary_extractor ||= BinaryMessaging::Extractor.new do |msg|
              message msg
            end
          end

          def extractor
            @extractor ||= Messaging::Extractor.new do |msg|
              message msg
            end
          end

          def capybara_webkit_protocol_parser
            @capybara_webkit_protocol_parser ||= CapybaraWebkitProtocolParser.new do |cmd|
            end
          end

          def message(s); end

          def render(path, width, height); end
        end
      end
    end
  end
end
