# frozen_string_literal: true

require 'capybara/webkit/daemon/binary_messaging'

module Capybara
  module Webkit
    module Daemon
      module BinaryMessaging
        ##
        # Inserts high-level binary packages to wrapped text protocol.
        #
        class Inserter
          include BinaryMessaging

          def initialize(&block)
            @block = block
          end

          def call(s)
            @block&.("#{HEADER_CHR}#{s.length}#{START_CHR}#{s}#{END_CHR}")
          end
        end
      end
    end
  end
end
