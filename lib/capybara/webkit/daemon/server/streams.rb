# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      module Server
        class Streams
          attr_reader :stdin, :stdout, :stderr

          def initialize(stdin:, stdout:, stderr:)
            self.stdin = stdin
            self.stdout = stdout
            self.stderr = stderr

            self.stdin.close unless self.stdin.closed?
          end

          def close
            stdout.close unless stdout.closed?
            stderr.close unless stderr.closed?
          end

        private

          attr_writer :stdin, :stdout, :stderr
        end
      end
    end
  end
end
