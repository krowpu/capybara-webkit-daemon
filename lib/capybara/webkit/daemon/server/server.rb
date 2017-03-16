# frozen_string_literal: true

require 'capybara/webkit/server'
require 'capybara'
require 'capybara/webkit/errors'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Server < Capybara::Webkit::Server
          SERVER_PATH = Capybara::Webkit::Server::SERVER_PATH

          attr_reader :configuration

          attr_reader :stderr

          def initialize(configuration:)
            @configuration = configuration

            super stderr: nil

            open_pipe
            discover_port
            discover_pid
            forward_output_in_background_thread

            @active = true
          end

          def start; end

          def active?
            @active
          end

          def close
            close_mutex.synchronize do
              raise 'server already closed' unless active?
              safe_close
            end
          end

        private

          def close_mutex
            @close_mutex ||= Mutex.new
          end

          def safe_close
            @active = false

            close_process
          end

          def close_process
            pid = @pid

            @port = nil
            @pid = nil

            Process.kill :KILL, pid
          end

          def open_pipe
            @pipe_stdin,
              @pipe_stdout,
              @pipe_stderr,
              @wait_thr = Open3.popen3(env, SERVER_PATH)
          end

          def env
            return @env if @env
            env = {}
            env['DISPLAY'] = configuration.to_h[:display] if configuration.to_h[:display]
            @env = env.freeze
          end
        end
      end
    end
  end
end
