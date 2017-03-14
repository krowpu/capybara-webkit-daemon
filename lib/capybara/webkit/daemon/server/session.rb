# frozen_string_literal: true

require 'capybara/webkit/daemon/server/browser'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Session
          attr_reader :client
          attr_reader :configuration

          def initialize(client, configuration:)
            @client = client
            @configuration = configuration
            browser
          end

          def browser
            @browser ||= Browser.new configuration: configuration
          end
        end
      end
    end
  end
end
