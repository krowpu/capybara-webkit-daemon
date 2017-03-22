# frozen_string_literal: true

require 'capybara/webkit/daemon/duration'

module Scrapod
  module Server
    class Configuration
      LOG_LEVELS = %i(debug info warn).freeze
      PORT_RE = /\A\d+\z/
      DISPLAY_RE = /\A:\d+\z/

      DEFAULTS = {
        help:                 false,
        config_file:          nil,
        pid_file:             nil,
        log_file:             nil,
        log_level:            :info,
        binding:              nil,
        port:                 20_885,
        display:              nil,
        max_session_duration: 5 * 60, # 5 minutes
        redis_url:            nil,
      }.freeze

      attr_reader :help
      attr_reader :config_file
      attr_reader :pid_file
      attr_reader :log_file, :log_level
      attr_reader :binding, :port
      attr_reader :display
      attr_reader :max_session_duration
      attr_reader :redis_url

      def initialize
        DEFAULTS.each do |k, v|
          send :"#{k}=", v
        end
      end

      def to_h
        DEFAULTS.map do |k, _v|
          [k, send(k)]
        end.to_h.freeze
      end

      def help=(value)
        @help = !!value
      end

      def config_file=(value)
        return @config_file = nil if value.nil?

        raise TypeError, "expected a #{String}" unless value.is_a? String
        @config_file = value.to_s
      end

      def pid_file=(value)
        return @pid_file = nil if value.nil?

        raise TypeError, "expected a #{String}" unless value.is_a? String
        @pid_file = value.to_s
      end

      def log_file=(value)
        return @log_file = nil if value.nil?

        raise TypeError, "expected a #{String}" unless value.is_a? String
        @log_file = value
      end

      def log_level=(value)
        value = value.to_sym

        unless LOG_LEVELS.include? value
          raise ArgumentError, "expected #{LOG_LEVELS.map(&:inspect).join(', ')}"
        end

        @log_level = value
      end

      def binding=(value)
        return @binding = nil if value.nil?

        raise TypeError, "expected a #{String}" unless value.is_a? String
        @binding = value
      end

      def port=(value)
        value = value.to_s
        raise ArgumentError, "invalid port value #{value.inspect}" unless value =~ PORT_RE
        @port = value.to_i
      end

      def display=(value)
        return @display = nil if value.nil?

        raise ArgumentError, "invalid display value #{value.inspect}" unless value =~ DISPLAY_RE
        @display = value
      end

      def max_session_duration=(value)
        if value.is_a? Integer
          raise ArgumentError, "invalid duration value #{value.inspect}" unless value.positive?
          @max_session_duration = value
          return
        end

        @max_session_duration = Capybara::Webkit::Daemon::Duration.new(value).to_secs
      end

      def redis_url=(value)
        return @redis_url = nil if value.nil?

        raise TypeError, "expected a #{String}" unless value.is_a? String
        @redis_url = value
      end
    end
  end
end
