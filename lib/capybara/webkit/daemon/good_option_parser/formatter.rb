# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      class GoodOptionParser
        class Formatter
          attr_reader :options

          def initialize(options)
            @options = options.map { |option| Line.new option }.freeze
          end

          def call
            ''
          end

          class Line
            attr_reader :option

            def initialize(option)
              @option = option
            end
          end
        end
      end
    end
  end
end
