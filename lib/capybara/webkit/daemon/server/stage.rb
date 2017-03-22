# frozen_string_literal: true

require 'scrapod/server/configuration'
require 'capybara/webkit/daemon/server/arguments'
require 'capybara/webkit/daemon/server/environments'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Stage
          attr_reader :argv, :env
          attr_reader :configuration

          def initialize(argv: nil, env: nil)
            self.argv = argv
            self.env = env

            set_configuration
          end

          def arguments
            @arguments ||= Arguments.new argv if argv
          end

          def environments
            @environments ||= Environments.new env if env
          end

        private

          def set_configuration
            configuration = Scrapod::Server::Configuration.new

            environments&.(configuration)
            arguments&.(configuration)

            @configuration = configuration.freeze
          end

          def argv=(argv)
            return @argv = nil if argv.nil?

            @argv = argv.map do |arg|
              arg.to_s.dup.freeze
            end.freeze
          end

          def env=(env)
            return @env = nil if env.nil?

            @env = env.map do |k, v|
              [
                k.to_s.dup.freeze,
                v.to_s.dup.freeze,
              ]
            end.to_h.freeze
          end
        end
      end
    end
  end
end
