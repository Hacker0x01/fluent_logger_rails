# frozen_string_literal: true

class JsonFormatter < HashFormatter
  def call(severity, timestamp, progname, msg)
    super(severity, timestamp, progname, msg).to_json
  end
end
