# frozen_string_literal: true

require 'capybara/webkit/daemon/server/extractor'
require 'capybara/webkit/daemon/server/inserter'

module Capybara
  module Webkit
    module Daemon
      module Server
        class Link
          attr_reader :extractor, :inserter

          def initialize(client:, server:)
            @extractor = Extractor.new source: client, destination: server
            @inserter = Inserter.new source: server, destination: client
          end

          def start
            extractor_thread
            inserter_thread
          ensure
            extractor_thread&.join
            inserter_thread&.join
          end

          def terminate!
            @terminating = true
          end

        private

          def extractor_thread
            @extractor_thread ||= Thread.start do
              begin
                extractor.round until @terminating
              rescue EOFError
                @terminating = true
              end
            end
          end

          def inserter_thread
            @inserter_thread ||= Thread.start do
              begin
                inserter.round until @terminating
              rescue EOFError
                @terminating = true
              end
            end
          end
        end
      end
    end
  end
end
