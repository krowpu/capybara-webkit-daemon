# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      class GoodOptionParser
        class Formatter
          attr_reader :options

          def initialize(options)
            @options = options.map { |option| Line.new self, option }.freeze
          end

          def call
            ''
          end

          class Line
            attr_reader :formatter, :option

            def initialize(formatter, option)
              @formatter = formatter
              @option = option
            end
          end
        end
      end
    end
  end
end
