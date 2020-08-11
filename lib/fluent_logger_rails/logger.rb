# frozen_string_literal: true
require 'active_support'

module FluentLoggerRails
  class Logger < ::ActiveSupport::Logger
    def initialize(logger, path:, level:)
      @level = SEV_LABEL.index(level.to_s.upcase)
      @path = path
      @logger = logger
      after_initialize if respond_to? :after_initialize
    end

    def add(severity, message = nil, progname = nil)
      return true if severity < @level

      message = (block_given? ? yield : progname) if message.blank?
      return true if message.blank?

      message = format_message(severity, Time.now, progname, message)

      @logger.post(@path, message)
      true
    end

    def close
      @logger.close
    end

    delegate :add_tags, :remove_tags, :clear_tags!, to: :formatter

    def tagged(*tags)
      formatter.tagged(*tags) { yield self }
    end

    def flush
      clear_tags!
      super if defined?(super)
    end
  end
end
