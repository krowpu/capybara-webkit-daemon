# frozen_string_literal: true

require 'capybara/webkit/daemon/server/wrapper'
require 'capybara/webkit/daemon/extractor'

module Capybara
  module Webkit
    module Daemon
      module Server
        class ClientToServerWrapper < Wrapper
          STATES = %i(name arg_size arg).freeze

          def initialize(*)
            super

            self.state = :name
          end

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

          def state=(sym)
            unless STATES.include? sym
              raise(
                ArgumentError,
                "invalid state #{sym.inspect}, possible are #{STATES.map(&:inspect).join(', ')}",
              )
            end

            @state = sym
          end
        end
      end
    end
  end
end
