# frozen_string_literal: true

require 'aasm'

module Capybara
  module Webkit
    module Daemon
      module Server
        class CapybaraWebkitProtocolParser
          include AASM

          aasm do
            state :name, initial: true, before_enter: :getting_name,       after_exit: :got_name
            state :args_count,          before_enter: :getting_args_count, after_exit: :got_args_count
            state :arg_size,            before_enter: :getting_arg_size,   after_exit: :got_arg_size
            state :arg,                 before_enter: :getting_arg,        after_exit: :got_arg

            event :newline do
              transitions from: :name, to: :args_count
            end

            event :newline do
              transitions from: :args_count, to: :name
              transitions from: :args_count, to: :arg_size
            end

            event :newline do
              transitions from: :arg_size, to: :name
              transitions from: :arg_size, to: :arg_size
              transitions from: :arg_size, to: :arg
            end

            event :arg_ended do
              transitions from: :arg, to: :name
              transitions from: :arg, to: :arg_size
            end
          end

          def call(s)
            s
          end

        private

          def getting_name
            @name = ''
          end

          def got_name
            @name = nil
          end

          def getting_args_count
            @args_count = ''
          end

          def got_args_count
            @args_count = nil
          end

          def getting_arg_size
            @arg_size = ''
          end

          def got_arg_size
            @arg_size = nil
          end

          def getting_arg
            @arg = ''
          end

          def got_arg
            @arg = nil
          end

          class Command
            attr_reader :name

            def initialize(name)
              raise TypeError, "expected name to be a #{String}" unless name.is_a? String

              @name = name.freeze
              @args_count = nil
              @args = []
            end

            def complete?
              @args_count && @args && @args.size == @args_count && @args.all?(&:complete?)
            end

            def args_count=(value)
              raise 'args count already set'                                            unless @args_count.nil?
              raise TypeError, "expected args count to be an #{Integer}"                unless value.is_a? Integer
              raise ArgumentError, 'expected args count to be greater or equal to zero' unless value >= 0
              @args_count = value
            end

            def <<(arg_size)
              raise 'args are already complete' if complete?
              @args << Arg.new(arg_size)
              nil
            end

            def last
              @args.fetch @args.size - 1
            end

            def to_s
              raise 'not yet complete' unless complete?
            end

            class Arg
              attr_reader :size

              def initialize(size)
                raise TypeError, "expected size to be an #{Integer}"                unless size.is_a? Integer
                raise ArgumentError, 'expected size to be greater or equal to zero' unless size >= 0

                @size = size
                @value = ''
              end

              def complete?
                @value.size == size
              end

              def <<(c)
                raise 'arg is already complete' if complete?
                @value += c
                nil
              end
            end
          end
        end
      end
    end
  end
end
