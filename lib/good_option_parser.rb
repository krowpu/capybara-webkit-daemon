# frozen_string_literal: true

require 'good_option_parser/options'
require 'good_option_parser/parser'

class GoodOptionParser
  def self.options
    @options ||= Options.new
  end

  def self.on(*args, &block)
    case args.length
    when 3
      on_both(*args, &block)
    when 2
      on_some(*args, &block)
    when 1
      on_no_description(*args, &block)
    else
      raise ArgumentError, 'invalid option signature'
    end
  end

  def self.on_both(short, long, description = nil, &block)
    options << Option.new(short, long, description, &block)
  end

  def self.on_some(short_or_long, long_or_description, &block)
    if long_or_description.start_with? '-'
      on_both(short_or_long, long_or_description, &block)
    elsif short_or_long.start_with? '--'
      on_long(short_or_long, long_or_description, &block)
    else
      on_short(short_or_long, long_or_description, &block)
    end
  end

  def self.on_no_description(short_or_long, &block)
    if short_or_long.start_with? '--'
      on_long(short_or_long, &block)
    else
      on_short(short_or_long, &block)
    end
  end

  def self.on_short(short, description = nil, &block)
    options << Option.new(short, nil, description, &block)
  end

  def self.on_long(long, description = nil, &block)
    options << Option.new(nil, long, description, &block)
  end

  attr_reader :argv

  def initialize(argv)
    self.argv = argv
  end

  def tokenized
    @tokenized ||= tokenize(argv).freeze
  end

  def parse(initial)
    Parser.new(self.class.options, tokenized, initial).config
  end

private

  def argv=(argv)
    @argv = argv.map do |arg|
      raise TypeError unless arg.is_a? String
      arg.dup.freeze
    end.freeze
  end

  def tokenize(args)
    return [] if args.empty?

    head, *tail = args

    case head
    when /\A-(\w)(.+)\z/ then ["-#$1", $2.freeze]
    when /\A-(\w)\z/     then ["-#$1"]
    when /\A--(.+)\z/    then ["--#$1"]
    else                      [head]
    end + tokenize(tail)
  end
end
