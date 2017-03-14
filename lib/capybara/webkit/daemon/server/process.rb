# frozen_string_literal: true

require 'capybara/webkit/daemon/server/configuration'
require 'capybara/webkit/daemon/server/streams'
require 'capybara/webkit/daemon/server/pid_file'
require 'capybara/webkit/daemon/server/signal_handler'
require 'capybara/webkit/daemon/server/logger'
require 'capybara/webkit/daemon/server/listener'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Process
          attr_reader :program_name, :argv, :env, :stdin, :stdout, :stderr

          def initialize(program_name:, # rubocop:disable Metrics/ParameterLists
                         argv:,
                         env:,
                         stdin:,
                         stdout:,
                         stderr:)
            self.program_name = program_name
            self.argv = argv
            self.env = env
            self.stdin = stdin
            self.stdout = stdout
            self.stderr = stderr
          end

          def start # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
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

          attr_writer :stdin, :stdout, :stderr

          def program_name=(program_name)
            @program_name = program_name.to_s.dup.freeze
          end

          def argv=(argv)
            @argv = argv.map { |arg| arg.to_s.dup.freeze }.freeze
          end

          def env=(env)
            @env = env.map do |k, v|
              [
                k.to_s.dup.freeze,
                v.to_s.dup.freeze,
              ]
            end.to_h.freeze
          end

          def listener
            @listener ||= Listener.new(
              configuration: configuration,
              logger: logger,
              binding: configuration.to_h[:binding],
              port: configuration.to_h[:port],
            )
          end

          def close_output
            logger.close
            streams.close
          end

          def streams
            @streams ||= Streams.new stdin: stdin, stdout: stdout, stderr: stderr
          end

          def pid_file
            return @pid_file if @pid_file
            filename = configuration.to_h[:pid_file]
            return if filename.nil?
            @pid_file ||= PidFile.new filename: filename, logger: logger
          end

          def logger
            @logger ||= Logger.new(
              program_name: program_name,
              configuration: configuration,
              streams: streams,
            )
          end
        end
      end
    end
  end
end
