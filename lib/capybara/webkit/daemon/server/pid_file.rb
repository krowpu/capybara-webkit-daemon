# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      module Server
        class PidFile
          attr_reader :filename, :logger
          private :logger

          def initialize(filename:, logger:)
            @filename = ::File.expand_path(filename).freeze
            @logger = logger
          end

          def create
            ::File.open filename, 'w' do |f|
              f.puts ::Process.pid
            end
          end

          def delete
            ::File.delete filename
          rescue
            logger.warn "Can not delete PID file #{filename}"
          end
        end
      end
    end
  end
end
