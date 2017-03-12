# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      module Server
        class Arguments
          attr_reader :argv

          def initialize(argv)
            @argv = argv.map { |arg| arg.to_s.dup.freeze }.freeze
          end

          def tokenized
            @tokenized ||= tokenize(argv).freeze
          end

          def parsed
            @parsed ||= parse(tokenized).freeze
          end

          alias to_h parsed

        private

          def tokenize(args)
            return [] if args.empty?

            head, *tail = args

            case head
            when /\A-(\w)(.+)\z/ then ["-#$1", $2.freeze]
            when /\A-(\w)\z/     then ["-#$1"]
            when /\A--(.+)\z/    then ["--#$1"]
            else                      [head]
            end + tokenize(tail)
          end

          def parse(tokens) # rubocop:disable MethodLength, AbcSize, CyclomaticComplexity
            return {} if tokens.empty?

            case tokens.first
            when '-q', '--quiet'
              { log_level: :warn }.merge parse tokens.drop 1
            when '-D', '--debug'
              { log_level: :debug }.merge parse tokens.drop 1
            when '-b', '--binding'
              { binding: tokens[1] }.merge parse tokens.drop 2
            when '-p', '--port'
              { port: parse_port(tokens[1]) }.merge parse tokens.drop 2
            when '-L', '--logfile'
              { log_file: tokens[1] }.merge parse tokens.drop 2
            when '-P', '--pidfile'
              { pid_file: tokens[1] }.merge parse tokens.drop 2
            else
              raise
            end
          end

          def parse_port(s)
            raise unless s =~ /\A\d+\z/
            s.to_i
          end
        end
      end
    end
  end
end
