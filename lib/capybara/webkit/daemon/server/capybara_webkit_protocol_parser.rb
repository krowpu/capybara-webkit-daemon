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
              transitions from: :name, to: :args_count

              transitions from: :args_count, to: :name, guard: :zero_args?
              transitions from: :args_count, to: :arg_size

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
        end
      end
    end
  end
end
