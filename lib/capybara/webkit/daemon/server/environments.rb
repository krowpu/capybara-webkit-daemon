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

          def call(configuration)
            configuration.log_level = env_log_level if env_log_level
            configuration.binding   = env_binding   if env_binding
            configuration.port      = env_port      if env_port
            configuration.display   = env_display   if env_display
          end

          def env_log_level
            env['CAPYBARA_WEBKIT_DAEMON_LOG_LEVEL']
          end

          def env_binding
            env['CAPYBARA_WEBKIT_DAEMON_BINDING']
          end

          def env_port
            env['CAPYBARA_WEBKIT_DAEMON_PORT']
          end

          def env_display
            env['CAPYBARA_WEBKIT_DAEMON_DISPLAY']
          end
        end
      end
    end
  end
end
