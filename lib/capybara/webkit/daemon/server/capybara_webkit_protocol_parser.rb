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

            event :newline, after: :got_name do
              transitions from: :name, to: :args_count
            end

            event :newline, after: :got_args_count do
              transitions from: :args_count, to: :name, guard: :zero_args?
              transitions from: :args_count, to: :arg_size
            end

            event :newline, after: :got_arg_size do
              transitions from: :arg_size, to: :name, guards: %i(empty_arg? last_arg?)
              transitions from: :arg_size, to: :arg_size, guard: :empty_arg?
              transitions from: :arg_size, to: :arg
            end

            event :arg_ended, after: :got_arg do
              transitions from: :arg, to: :name, guard: :last_arg?
              transitions from: :arg, to: :arg_size
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
