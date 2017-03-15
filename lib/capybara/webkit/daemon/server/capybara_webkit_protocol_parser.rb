# frozen_string_literal: true

module Capybara
  module Webkit
    module Daemon
      module Server
        class CapybaraWebkitProtocolParser
          def initialize(&block)
            @block = block
            @state = Name.new
            @result = ''
          end

          def call(s)
            return s if @block.nil?

            s.each_char do |c|
              @state = @state.(c, &cb)
            end

            result = @result
            @result = ''
            result
          end

          def cb
            @cb ||= method :command
          end

          def command(name, args)
            @result += serialize name, args if @block.nil? || !@block.(name, args)
          end

          def serialize(name, args)
            "#{name}\n#{args.count}\n#{args.map { |arg| "#{arg.bytesize}\n#{arg}" }.join}"
          end

          class State
            def call(_c)
              raise NotImplementedError, "#{self.class}#call"
            end

            def inspect
              "#{inspect_name}(#{inspect_ivars})"
            end

            def inspect_name
              self.class.name.split('::').last
            end

            def inspect_ivars
              instance_variables.map { |v| "#{v[1..-1]}: #{instance_variable_get(v).inspect}" }.join ', '
            end
          end

          class Name < State
            def initialize
              @name = ''
            end

            def call(c)
              return ArgsCount.new @name if c == "\n"
              @name += c
              self
            end
          end

          class ArgsCount < State
            def initialize(name)
              raise 'name can not be empty' if name.empty?
              @name = name
              @args_count = ''
            end

            def call(c)
              if c == "\n"
                if @args_count == '0'
                  yield @name, []
                  return Name.new
                end
                return ArgSize.new @name, @args_count
              end

              @args_count += c
              self
            end
          end

          class ArgSize < State
            def initialize(name, args_count, args: [], arg_size: '')
              @name = name
              @args_count = Integer args_count
              @args = args
              @arg_size = arg_size
            end

            def call(c)
              if c == "\n"
                if @arg_size == '0'
                  @args << ''
                  if @args.count == @args_count
                    yield @name, @args
                    return Name.new
                  end
                  return ArgSize.new @name, @args_count, args: @args
                end
                return Arg.new @name, @args_count, @args, @arg_size
              end

              @arg_size += c
              self
            end
          end

          class Arg < State
            def initialize(name, args_count, args, arg_size)
              @name = name
              @args_count = args_count
              @args = args
              @arg_size = Integer arg_size
              @arg = ''
            end

            def call(c)
              if @arg.size == @arg_size
                @args << @arg
                if @args.count == @args_count
                  yield @name, @args
                  return Name.new
                end
                return ArgSize.new @name, @args_count, args: @args, arg_size: c
              end

              @arg += c
              self
            end
          end
        end
      end
    end
  end
end
