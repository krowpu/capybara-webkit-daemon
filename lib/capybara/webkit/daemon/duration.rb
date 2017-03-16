# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      ##
      # Simple time duration format.
      #
      class Duration
        attr_reader :to_s

        def initialize(s)
          raise TypeError, "expectedduration to be a #{String}" unless s.is_a? String
          raise ArgumentError, 'empty duration string' if s.empty?
          @to_s = s.dup.freeze
          raise ArgumentError, 'invalid duration string format' if match.nil?
          to_secs
        end

        def to_secs
          @to_secs ||=
            match_days  +
            match_hours +
            match_mins  +
            match_secs
        end

      private

        RE = /\A((?<days>\d+)d)?((?<hours>\d+)h)?((?<mins>\d+)m)?((?<secs>\d+)s)?\z/

        DAYS  = 24 * 60 * 60
        HOURS = 60 * 60
        MINS  = 60

        def match
          @match ||= to_s.match RE
        end

        def match_days
          @match_days ||= match[:days].to_i * DAYS
        end

        def match_hours
          @match_hours ||=
            begin
              result = match[:hours].to_i
              raise ArgumentError, "too many hours: #{result}" if result >= 24
              result * HOURS
            end
        end

        def match_mins
          @match_mins ||=
            begin
              result = match[:mins].to_i
              raise ArgumentError, "too many minutes: #{result}" if result >= 60
              result * MINS
            end
        end

        def match_secs
          @match_secs ||=
            begin
              result = match[:secs].to_i
              raise ArgumentError, "too many seconds: #{result}" if result >= 60
              result
            end
        end
      end
    end
  end
end
