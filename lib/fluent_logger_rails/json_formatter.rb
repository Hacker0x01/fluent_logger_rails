# frozen_string_literal: true

module FluentLoggerRails
  class JsonFormatter < HashFormatter
    def call(severity, timestamp, progname, msg)
      super(severity, timestamp, progname, msg).to_json
    end
  end
end
