# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      class GoodOptionParser
        class Formatter
          attr_reader :lines

          def initialize(options)
            @lines = options.map { |option| Line.new self, option }.freeze
          end

          def call
            ''
          end

          def has_short?
            @has_short ||= lines.any?(&:has_short?)
          end

          def has_long?
            @has_long ||= lines.any?(&:has_long?)
          end

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
