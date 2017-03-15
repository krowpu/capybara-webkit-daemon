# frozen_string_literal: true

require 'capybara/webkit/daemon/server/wrapper'
require 'capybara/webkit/daemon/extractor'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Extractor < Wrapper
        private

          def extractor
            @extractor ||= Daemon::Extractor.new do |msg|
              message msg
            end
          end

          def message(s); end

          def scan(s)
            raw extractor.call s
          end
        end
      end
    end
  end
end
