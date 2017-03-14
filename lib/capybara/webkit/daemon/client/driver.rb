# frozen_string_literal: true

require 'capybara/webkit/driver'

require 'capybara/webkit/daemon/client/connection'
require 'capybara/webkit/daemon/client/browser'

module Capybara
  module Webkit
    module Daemon
      module Client
        class Driver < Capybara::Webkit::Driver
          def initialize(app, options = {})
            @app = app
            @options = options.dup
            @options[:server] ||= Server.new(options)
            @browser = options[:browser] || Browser.new(Connection.new(@options))
            apply_options
          end
        end
      end
    end
  end
end
