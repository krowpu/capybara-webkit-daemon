# frozen_string_literal: true

require 'logger'

require 'capybara/webkit/daemon/server/configuration'
require 'capybara/webkit/daemon/server/pid_file'
require 'capybara/webkit/daemon/server/signal_handler'
require 'capybara/webkit/daemon/server/listener'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Process
          attr_reader :program_name, :argv, :env, :stdin, :stdout, :stderr

          def initialize(program_name:, # rubocop:disable ParameterLists, MethodLength, AbcSize
                         argv:,
                         env:,
                         stdin:,
                         stdout:,
                         stderr:)
            @program_name = program_name.to_s.dup.freeze

            @argv = argv.map { |arg| arg.to_s.dup.freeze }.freeze

            @env = env.map do |k, v|
              [
                k.to_s.dup.freeze,
                v.to_s.dup.freeze,
              ]
            end.to_h.freeze

            @stdin  = stdin
            @stdout = stdout
            @stderr = stderr
          end

          def start # rubocop:disable Metrics/AbcSize
            logger.info "Running in #{RUBY_DESCRIPTION}"
            logger.debug "Configuration: #{configuration.to_h.inspect}"

            if configuration.to_h[:help]
              return stderr.print Arguments::OptionParser.options.description
            end

            pid_file&.create

            listener.start

          rescue Exception => e # rubocop:disable Lint/RescueException
            logger.fatal e
            raise
          ensure
            pid_file&.delete
            close_output
          end

          def configuration
            @configuration ||= Configuration.new argv: argv, env: env
          end

          def signal_handler
            @signal_handler ||= SignalHandler.new listener: listener, logger: logger
          end

        private

          def listener
            @listener ||= Listener.new(
              logger: logger,
              binding: configuration.to_h[:binding],
              port: configuration.to_h[:port],
            )
          end

          def close_output
            logger.close
            stdout.close unless stdout.closed?
            stderr.close unless stderr.closed?
          end

          def pid_file
            return @pid_file if @pid_file
            filename = configuration.to_h[:pid_file]
            return if filename.nil?
            @pid_file ||= PidFile.new filename: filename, logger: logger
          end

          def logger
            return @logger if @logger

            logger = Logger.new log_file

            logger.progname = log_progname
            logger.level    = log_level

            @logger = logger
          end

          def log_file
            configuration.to_h[:log_file] || stderr
          end

          def log_progname
            program_name
          end

          def log_level
            case configuration.to_h[:log_level]
            when :debug then Logger::DEBUG
            when :info  then Logger::INFO
            when :warn  then Logger::WARN
            else
              raise
            end
          end
        end
      end
    end
  end
end
