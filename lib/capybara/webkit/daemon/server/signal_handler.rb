# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      module Server
        class SignalHandler
          INTERRUPTION_TIMEOUT = 5

          attr_reader :logger, :listener
          private     :logger, :listener

          def initialize(logger:, listener:)
            @logger = logger
            @listener = listener
          end

          def sigterm!
            Thread.start do
              log_signal :TERM
              listener.terminate!
            end
          end

          def sigint!
            Thread.start do
              log_signal :INT
              listener.stop_accepting_new_connections!
              sleep INTERRUPTION_TIMEOUT
              listener.terminate!
            end
          end

          def sigquit!
            Thread.start do
              log_signal :QUIT
              listener.stop_accepting_new_connections!
            end
          end

          def sighup!
            Thread.start do
              log_signal :HUP
            end
          end

        private

          def log_signal(sig)
            logger.info "SIG#{sig} received"
          end
        end
      end
    end
  end
end
