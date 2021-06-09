# frozen_string_literal: true

module FluentLoggerRails
  class TaggedHashFormatter < ::Logger::Formatter
    # Parent key - ensures that if the log is being merged into a higher level payload this key can
    # be set in order to not conflict or be overridden.
    attr_accessor :parent_key

    def initialize(merge_message_into_payload = false)
      super()
      @merge_message_into_payload = merge_message_into_payload
      # Override the Logger::Formatter default to a format that does not have a trailing space
      @datetime_format = "%Y-%m-%dT%H:%M:%S.%6N"
    end

    def call(severity, timestamp, _progname, msg)
      payload = if msg.is_a?(Hash) && @merge_message_into_payload
        msg
      else
        {
          message: msg.is_a?(String) ? msg.strip : msg,
        }
      end

      payload = payload.merge(
        {
          severity: format_severity(severity),
          timestamp: format_datetime(timestamp),
        },
      ).merge(compact_tags.deep_dup)

      @parent_key ? { @parent_key => payload } : payload
    end

    def format_severity(severity)
      if severity.blank?
        'ANY'
      elsif severity.is_a? Integer
        ActiveSupport::Logger::SEV_LABEL[severity]
      else
        severity
      end
    end

    def tagged(*tags)
      add_tags(*tags)
      yield self
    ensure
      remove_tags(*tags)
    end

    def add_tags(*tags)
      tags = tags.first if tags.length == 1

      if tags.is_a? Array
        current_tags[:tags] ||= []
        current_tags[:tags] += tags
      elsif tags.is_a? String
        current_tags[:tags] ||= []
        current_tags[:tags] << tags
      else
        current_tags.merge! tags
      end
    end

    def remove_tags(*tags)
      tags = tags.first if tags.length == 1

      if tags.is_a? Array
        current_tags[:tags] ||= []
        tags.each { |tag| current_tags[:tags].delete(tag) }
      elsif tags.is_a? String
        current_tags[:tags] ||= []
        current_tags[:tags].delete(tags)
      else
        tags.each_key { |key| current_tags.delete(key) }
      end
    end

    def clear_tags!
      current_tags.clear
    end

    def current_tags
      # We use our object ID here to avoid conflicting with other instances
      thread_key = @thread_key ||= "fluent_logger_rails:#{object_id}"
      Thread.current[thread_key] ||= {}
    end

    def compact_tags
      current_tags.delete_if { |_k, v| v.blank? }
    end
  end
end
