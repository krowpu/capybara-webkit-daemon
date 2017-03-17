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
            raise 'global variable $config is in use' unless $config.nil?

            $config = configuration
            load path
            $config = nil
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
