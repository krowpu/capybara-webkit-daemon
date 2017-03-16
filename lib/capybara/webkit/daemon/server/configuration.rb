# frozen_string_literal: true

require 'capybara/webkit/daemon/common'
require 'capybara/webkit/daemon/server/arguments'
require 'capybara/webkit/daemon/server/environments'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Configuration
          DEFAULTS = {
            help: false,
            pid_file: nil,
            log_file: nil,
            log_level: :info,
            binding: nil,
            port: Common::DEFAULT_PORT,
            display: nil,
            max_session_duration: Common::DEFAULT_MAX_SESSION_DURATION,
          }.freeze

          attr_reader :argv, :env

          def initialize(argv: nil, env: nil)
            @argv = argv.map { |arg| arg.to_s.dup.freeze }.freeze if argv

            env and
              @env = env.map do |k, v|
                [
                  k.to_s.dup.freeze,
                  v.to_s.dup.freeze,
                ]
              end.to_h.freeze
          end

          def to_h
            @to_h ||= [
              DEFAULTS,
              environments&.to_h,
              arguments&.to_h,
            ].compact.inject(&:merge).freeze
          end

          def arguments
            @arguments ||= Arguments.new argv if argv
          end

          def environments
            @environments ||= Environments.new env if env
          end
        end
      end
    end
  end
end
