# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      module Server
        class CapybaraWebkitProtocolParser
          def initialize(&block)
            @block = block
          end

          def call(s)
            return s if @block.nil?
            return s unless @block&.(s)
            ''
          end
        end
      end
    end
  end
end
