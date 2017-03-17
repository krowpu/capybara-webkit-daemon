# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      module Server
        class ConfigFile
          attr_reader :path

          def initialize(path)
            self.path = path
          end

          def call(configuration)
            raise 'global variable $capybara_webkit_daemon_config is in use' unless $capybara_webkit_daemon_config.nil?

            $capybara_webkit_daemon_config = configuration
            load path
            $capybara_webkit_daemon_config = nil
          end

        private

          def path=(value)
            raise TypeError, "expected path to be a #{String}"                 unless value.is_a? String
            raise ArgumentError, "file #{value.inspect} is not a regular file" unless File.file? value

            @path = value.dup.freeze
          end
        end
      end
    end
  end
end
