# frozen_string_literal: true

require 'capybara'
require 'capybara/webkit/browser'

module Capybara
  module Webkit
    module Daemon
      module Client
        class Browser < Capybara::Webkit::Browser
        end
      end
    end
  end
end
