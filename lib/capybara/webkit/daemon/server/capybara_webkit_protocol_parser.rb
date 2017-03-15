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
              transitions from: :args_count, to: :name, guard: :zero_args?
              transitions from: :args_count, to: :arg_size
            end

            event :newline do
              transitions from: :arg_size, to: :name, guards: %i(empty_arg? last_arg?)
              transitions from: :arg_size, to: :arg_size, guard: :empty_arg?
              transitions from: :arg_size, to: :arg
            end

            event :arg_ended do
              transitions from: :arg, to: :name, guard: :last_arg?
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

          def zero_args?
            args_count.zero?
          end

          def empty_arg?
            arg_size.zero?
          end

          def args_count
            Integer @args_count
          end

          def arg_size
            Integer @arg_size
          end
        end
      end
    end
  end
end
