# frozen_string_literal: true

class GoodOptionParser
  class Parser
    attr_reader :args, :config

    def initialize(options, tokens, initial)
      @options = options
      @tokens = tokens.dup

      @args = []
      @config = initial

      round until @tokens.empty?
    end

  private

    attr_reader :options

    def round
      token = @tokens.shift
      option = options.match token
      return @config = option.block.(@config, method(:arg)) if option
      @args << token
    end

    def arg
      raise 'no option argument' if @tokens.empty?
      raise 'option argument if option' if options.match @tokens.first
      @tokens.shift
    end
  end
end
