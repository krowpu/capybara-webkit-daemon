# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      class GoodOptionParser
        class Formatter
          attr_reader :options

          def initialize(options)
            @options = options.dup.freeze
          end

          def call
            ''
          end
        end
      end
    end
  end
end
