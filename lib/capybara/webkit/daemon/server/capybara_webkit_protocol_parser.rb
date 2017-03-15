# frozen_string_literal: true

require 'aasm'

module Capybara
  module Webkit
    module Daemon
      module Server
        class CapybaraWebkitProtocolParser
          include AASM

          aasm do
            state :name, initial: true
            state :args_count
            state :arg_size
            state :arg

            event :newline do
              transitions from: :name, to: :args_count, after: :got_name

              transitions from: :args_count, to: :name,     after: :got_args_count, guard: :zero_args?
              transitions from: :args_count, to: :arg_size, after: :got_args_count

              transitions from: :arg_size, to: :name,     after: :got_arg_size, guards: %i(empty_arg? last_arg?)
              transitions from: :arg_size, to: :arg_size, after: :got_arg_size, guard: :empty_arg?
              transitions from: :arg_size, to: :arg,      after: :got_arg_size
            end

            event :arg_ended do
              transitions from: :arg, to: :name,     after: :got_arg, guard: :last_arg?
              transitions from: :arg, to: :arg_size, after: :got_arg
            end
          end

          def call(s)
            s
          end

        private

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
