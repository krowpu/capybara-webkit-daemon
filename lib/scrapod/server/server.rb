# frozen_string_literal: true

require 'capybara/webkit/server'
require 'capybara'
require 'capybara/webkit/errors'

module Scrapod
  module Server
    class Server < Capybara::Webkit::Server
      SERVER_PATH = Capybara::Webkit::Server::SERVER_PATH

      attr_reader :path
      attr_reader :configuration

      attr_reader :stderr

      def initialize(configuration:)
        self.path = SERVER_PATH

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
          return unless active?

          @active = false

          close_process
        end
      end

    private

      def path=(path)
        raise TypeError, "expected path to be a #{String}" unless path.is_a? String
        path = File.expand_path path
        raise ArgumentError, 'expected path to be a regular file'     unless File.file? path
        raise ArgumentError, 'expected path to be an executable file' unless File.executable? path
        @path = path.dup.freeze
      end

      def close_mutex
        @close_mutex ||= Mutex.new
      end

      def close_process
        pid = @pid

        @port = nil
        @pid = nil

        ::Process.kill :KILL, pid
      end

      def open_pipe
        @pipe_stdin,
          @pipe_stdout,
          @pipe_stderr,
          @wait_thr = Open3.popen3 env, path
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
