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

          def has_short?
            @has_short ||= options.any?(&:has_short?)
          end

          def has_long?
            @has_long ||= options.any?(&:has_long?)

          class Line
            attr_reader :formatter, :option

            def initialize(formatter, option)
              @formatter = formatter
              @option = option
            end

            def has_short?
              @has_short ||= !option.short.nil?
            end

            def has_long?
              @has_long ||= !option.long.nil?
            end
          end
        end
      end
    end
  end
end
