# frozen_string_literal: true

class GoodOptionParser
  class Formatter
    attr_reader :lines

    def initialize(options)
      @lines = options.map { |option| Line.new self, option }.freeze
    end

    def call
      @call ||= lines.map(&:to_s).join
    end

    def long_width
      @long_width ||= lines.map(&:long_width).max
    end

    class Line
      attr_reader :formatter, :option

      def initialize(formatter, option)
        @formatter = formatter
        @option = option
      end

      def to_s
        @to_s ||= "    #{short}#{long}#{description}".rstrip + "\n"
      end

      def short
        @short ||= option.short ? "#{option.short}#{option.long && ',' || ' '} " : '    '
      end

      def long
        @long ||= "#{option.long}#{' ' * (formatter.long_width - (option.long&.length || 0))}    "
      end

      def description
        @description ||= option.description || ''
      end

      def long_width
        @long_width ||= option.long ? option.long.length : 0
      end
    end
  end
end
