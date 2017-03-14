# frozen_string_literal: true

module Capybara; end

require 'capybara/webkit/connection'

require 'capybara/webkit/daemon/server/server'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Connection < Capybara::Webkit::Connection
          attr_reader :configuration

          attr_reader :socket

          def initialize(configuration:)
            @configuration = configuration
            super server: server
          end

          def server
            @server ||= Capybara::Webkit::Daemon::Server::Server.new(
              stderr: nil,
              configuration: configuration,
            )
          end

          def close
            `kill #{pid}`
          end
        end
      end
    end
  end
end
