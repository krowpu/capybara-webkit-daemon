# frozen_string_literal: true

require 'capybara/webkit/daemon/common'

module Capybara
  module Webkit
    module Daemon
      module Client
        class Server
          attr_reader :port

          def initialize(port: Common::DEFAULT_PORT)
            raise TypeError unless port.is_a? Integer

            @port = port
          end

          def start; end

          def pid
            raise NotImplementedError, "#{self.class}#pid can not be implemented"
          end
        end
      end
    end
  end
end
