# frozen_string_literal: true

class GoodOptionParser
  class Parser
    attr_reader :args, :config, :mutate_config

    def initialize(options, tokens, initial, mutate_config: false)
      @options = options
      @tokens = tokens.dup
      self.mutate_config = mutate_config

      @args = []
      @config = initial

      round until @tokens.empty?
    end

  private

    attr_reader :options

    def mutate_config=(value)
      @mutate_config = !!value
    end

    def round
      token = @tokens.shift

      option = options.match token

      if option
        new_config = option.block.(@config, method(:arg))
        @config = new_config unless mutate_config
        return
      end

      @args << token
    end

    def arg
      raise 'no option argument' if @tokens.empty?
      raise 'option argument if option' if options.match @tokens.first
      @tokens.shift
    end
  end
end
