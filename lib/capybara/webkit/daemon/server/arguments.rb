# frozen_string_literal: true

require 'good_option_parser'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Arguments
          attr_reader :option_parser

          def initialize(argv)
            @option_parser = OptionParser.new argv
          end

          def call(configuration)
            option_parser.parse configuration, mutate_config: true
          end

          class OptionParser < GoodOptionParser
            on '-h', '--help', 'Show this help' do |c|
              c.help = true
            end

            on '-q', '--quiet', 'Be quiet' do |c|
              c.log_level = :warn
            end

            on '-D', '--debug', 'Debug logging' do |c|
              c.log_level = :debug
            end

            on '-C', '--config', 'Configuration file' do |c, arg|
              c.config_file = arg.()
            end

            on '-b', '--binding', 'Bind to the specified IP' do |c, arg|
              c.binding = arg.()
            end

            on '-p', '--port', 'Run on the specified port' do |c, arg|
              c.port = arg.()
            end

            on '-L', '--logfile', 'Specify the log file' do |c, arg|
              c.log_file = arg.()
            end

            on '-P', '--pidfile', 'Specify the PID file' do |c, arg|
              c.pid_file = arg.()
            end

            on '-d', '--display', 'Specify Xvfb display' do |c, arg|
              c.display = arg.()
            end

            on '--max-session-duration', 'Specify max session duration (ex: "1h30m15s")' do |c, arg|
              c.max_session_duration = arg.()
            end
          end
        end
      end
    end
  end
end
