# frozen_string_literal: true

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

      raise ArgumentError, 'no option keys' if self.short.nil? && self.long.nil?
    end

    def duplicate_of?(other)
      short && short == other.short || long && long == other.long
    end

    def match?(token)
      token && (token == short || token == long)
    end

  private

    def short=(s)
      return @short = nil if s.nil?
      raise ArgumentError, 'invalid short option key' unless s =~ SHORT_RE
      @short = s.dup.freeze
    end

    def long=(s)
      return @long = nil if s.nil?
      raise ArgumentError, 'invalid long option key' unless s =~ LONG_RE
      @long = s.dup.freeze
    end

    def description=(s)
      return @description = nil if s.nil?
      raise TypeError, 'expected description to be a String' unless s.is_a? String
      @description = s.dup.freeze
    end

    def block=(block)
      raise TypeError, 'expected block to be a Proc' unless block.is_a? Proc
      @block = block
    end
  end
end
