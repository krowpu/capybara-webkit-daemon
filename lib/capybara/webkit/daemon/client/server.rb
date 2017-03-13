# frozen_string_literal: true

require 'capybara/webkit/daemon/common'

module Capybara
  module Webkit
    module Daemon
      module Client
        class Server
          attr_reader :host, :port

          def initialize(host: '127.0.0.1', port: Common::DEFAULT_PORT)
            raise TypeError unless host.is_a? String
            raise TypeError unless port.is_a? Integer

            @host = host.dup.freeze
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
