# frozen_string_literal: true

module FluentLoggerRails
  class PrettyJsonFormatter < HashFormatter
    def call(severity, timestamp, progname, msg)
      JSON.pretty_generate(super(severity, timestamp, progname, msg))
    end
  end
end
