# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      module Server
        class Session
          attr_reader :client

          def initialize(client)
            @client = client
          end
        end
      end
    end
  end
end
