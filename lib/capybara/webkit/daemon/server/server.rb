# frozen_string_literal: true

require 'capybara/webkit/server'
require 'capybara'
require 'capybara/webkit/errors'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Server < Capybara::Webkit::Server
          attr_reader :stderr, :configuration

          def initialize(*args)
            options = args.pop if args.last.is_a? Hash
            options ||= {}
            @configuration = options[:configuration]
            super(*args)
          end

        private

          def open_pipe
            @pipe_stdin,
              @pipe_stdout,
              @pipe_stderr,
              @wait_thr = Open3.popen3(env, self.class::SERVER_PATH)
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
