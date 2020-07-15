# frozen_string_literal: true

module FluentLoggerRails
  module TaggedLogging
    def self.new(logger, format: :hash)
      logger.formatter = if format == :hash
        HashFormatter.new
      elsif format == :pretty_json
        PrettyJsonFormatter.new
      elsif format == :json
        JsonFormatter.new
      else
        fail "Unrecognized log format: '#{format}'"
      end

      logger.extend(self)
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
