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
          end

          def call(s)
            s
          end
        end
      end
    end
  end
end
