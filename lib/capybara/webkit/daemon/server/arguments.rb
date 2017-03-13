# frozen_string_literal: true

require 'capybara/webkit/daemon/good_option_parser'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Arguments
          attr_reader :option_parser

          def initialize(argv)
            @option_parser = OptionParser.new argv
          end

          def to_h
            @to_h ||= option_parser.parse({})
          end

          class OptionParser < GoodOptionParser
            PORT_RE = /\A\d+\z/
            DISPLAY_RE = /\A:\d+\z/

            on '-h', '--help', 'Show this help' do |h|
              h.merge help: true
            end

            on '-q', '--quiet', 'Be quiet' do |h|
              h.merge log_level: :warn
            end

            on '-D', '--debug', 'Debug logging' do |h|
              h.merge log_level: :debug
            end

            on '-b', '--binding', 'Bind to the specified IP' do |h, arg|
              h.merge binding: arg.()
            end

            on '-p', '--port', 'Run on the specified port' do |h, arg|
              arg = arg.()
              raise ArgumentError, 'invalid port format' unless arg =~ PORT_RE
              h.merge port: arg.to_i
            end

            on '-L', '--logfile', 'Specify the log file' do |h, arg|
              h.merge log_file: arg.()
            end

            on '-P', '--pidfile', 'Specify the PID file' do |h, arg|
              h.merge pid_file: arg.()
            end

            on '-d', '--display', 'Specify Xvfb display' do |h, arg|
              arg = arg.()
              raise ArgumentError, 'invalid display format' unless arg =~ DISPLAY_RE
              h.merge display: arg
            end
          end
        end
      end
    end
  end
end
