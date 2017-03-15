# frozen_string_literal: true

require 'capybara/webkit/daemon/server/wrapper'
require 'capybara/webkit/daemon/extractor'

module Capybara
  module Webkit
    module Daemon
      module Server
        class ClientToServerWrapper < Wrapper
        private

          def scan(s)
            raw extractor.call s
          end

          def extractor
            @extractor ||= Daemon::Extractor.new do |msg|
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
