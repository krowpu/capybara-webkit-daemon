# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      module Server
        class Client
          attr_reader :socket

          def initialize(socket)
            @socket = socket
          end
        end
      end
    end
  end
end
