# frozen_string_literal: true

require 'capybara/webkit/daemon/good_option_parser/option'
require 'capybara/webkit/daemon/good_option_parser/formatter'

module Capybara
  module Webkit
    module Daemon
      class GoodOptionParser
        class Options
          def initialize
            @options = []
          end

          def <<(new_option)
            raise TypeError, "expected option to be a #{Option}" unless new_option.is_a? Option

            @options.each do |option|
              raise ArgumentError, 'duplicate option' if new_option.duplicate_of? option
            end

            @options << new_option
          end

          def match(token)
            @options.each do |option|
              return option if option.match? token
            end

            nil
          end

          def description
            Formatter.new(@options).call
          end
        end
      end
    end
  end
end
