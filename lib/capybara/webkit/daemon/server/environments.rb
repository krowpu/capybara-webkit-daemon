# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      module Server
        class Environments
          attr_reader :env

          def initialize(env)
            @env = env.map do |k, v|
              [
                k.to_s.dup.freeze,
                v.to_s.dup.freeze,
              ]
            end.to_h.freeze
          end

          def to_h
            return @to_h if @to_h

            h = {}

            h[:log_level] = parse_log_level if env_log_level
            h[:port]      = parse_port      if env_port

            @to_h = h.freeze
          end

          def parse_log_level
            env_log_level.downcase.to_sym
          end

          def parse_port
            raise unless env_port =~ /\A\d+\z/
            env_port.to_i
          end

          def env_log_level
            env['CAPYBARA_WEBKIT_DAEMON_LOG_LEVEL']
          end

          def env_port
            env['CAPYBARA_WEBKIT_DAEMON_PORT']
          end
        end
      end
    end
  end
end
