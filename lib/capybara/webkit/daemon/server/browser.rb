# frozen_string_literal: true

require 'capybara/webkit/browser'

require 'capybara/webkit/daemon/server/connection'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Browser < Capybara::Webkit::Browser
          attr_reader :configuration

          def initialize(configuration:)
            @configuration = configuration
            connection
          end

          def connection
            @connection ||= Connection.new configuration: configuration
          end
        end
      end
    end
  end
end
