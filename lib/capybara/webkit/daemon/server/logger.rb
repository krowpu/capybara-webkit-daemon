# frozen_string_literal: true

require 'logger'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Logger < Logger
          attr_reader :configuration, :streams

          def initialize(program_name:, configuration:, streams:)
            @configuration = configuration
            @streams = streams

            super log_file

            self.progname = program_name
            self.level = log_level
          end

        private

          def log_file
            configuration.to_h[:log_file] || streams.stderr
          end

          def log_level
            case configuration.to_h[:log_level]
            when :debug then ::Logger::DEBUG
            when :info  then ::Logger::INFO
            when :warn  then ::Logger::WARN
            else
              raise "invalid log level #{configuration.to_h[:log_leve].inspect}"
            end
          end
        end
      end
    end
  end
end
