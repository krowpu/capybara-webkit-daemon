# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      class GoodOptionParser
        class Option
          SHORT_RE = /\A-[a-z0-9]\z/i
          LONG_RE = /\A--[a-z0-9]+(-[a-z0-9]+)*\z/i

          attr_reader :short, :long, :description, :block

          def initialize(short, long, description = nil, &block)
            self.short = short
            self.long = long
            self.description = description
            self.block = block
          end

        private

          def short=(s)
            return @short = nil if s.nil?
            raise ArgumentError, 'invalid short option' unless s =~ SHORT_RE
            @short = s.dup.freeze
          end

          def long=(s)
            return @long = nil if s.nil?
            raise ArgumentError, 'invalid long option' unless s =~ LONG_RE
            @long = s.dup.freeze
          end

          def description=(s)
            return @description = nil if s.nil?
            raise TypeError, 'expected description to be a String' unless s.is_a? String
            @description = s.dup.freeze
          end

          def block=(block)
            return @block = nil if block.nil?
            raise TypeError, 'expected block to be a Proc' unless block.is_a? Proc
            @block = block
          end
        end
      end
    end
  end
end
