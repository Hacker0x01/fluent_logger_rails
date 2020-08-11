# Fluent Logger Rails

This is a library that wraps the [fluent-logger gem](https://github.com/fluent/fluent-logger-ruby) and provides easy integration with your Rails application. This includes log formatters that support [Rails tagged logging](https://api.rubyonrails.org/classes/ActiveSupport/TaggedLogging.html) for JSON format that can be sent to Fluentd (or really any other logging backend).

# Installation

```
gem install fluent_logger_rails
```

# How to configure

```ruby
Rails.application.configure do
  config.logger = FluentLoggerRails::Logger.new(
    ::Fluent::Logger::FluentLogger.new(
      nil,
      host: 'localhost',
      port: 24224,
    ),
    level: config.log_level
  )
end
```

## Formatter Configuration

This gem includes formatters that can be used with the logger to get JSON output that also supports [Rails tagged logging](https://api.rubyonrails.org/classes/ActiveSupport/TaggedLogging.html).

### JSON

This is a JSON formatter that supports tagged logging.
```ruby
config.logger.formatter = JsonFormatter.new
config.logger.formatter.datetime_format = '%Y-%m-%d %H:%M:%S.%3N%z'
config.logger.formatter.parent_key = 'payload'
```

### Pretty JSON

Similar JSON string logger (format is NOT actual JSON) that supports tagged logging and is useful for development or debugging.
```ruby
config.logger.formatter = PrettyJsonFormatter.new
```

### Standard Rails Tagged Logger

The standard Rails tagged logger works as well.
```ruby
ActiveSupport::TaggedLogging.new(config.logger)
```

# Examples

## Simple JSON Tagged Logging
```ruby
Rails.logger.tagged(user.id) do
  Rails.logger.warn('UserUpdateJob failed')
end

#
# Outputs:
#
# {
#   "tags": [1234],
#   "message": "UserUpdateJob failed", 
#   "severity": "WARN",
#   "timestamp": "2019-01-08 14:51:39.701-0800", 
# }
```

## JSON Tagged Logging

```ruby
Rails.logger.tagged(user_id: user.id, session_id: user_session.id) do
  Rails.logger.info('UserUpdateJob failed', args: args)
end

#
# Outputs:
#
# {
#   "user_id": 1234,
#   "session_id": 883839,
#   "message": {
#     "message": "UserUpdateJob failed",
#     "args": [1,2,3]
#   }, 
#   "severity": "INFO",
#   "timestamp": "2019-01-08 14:51:39.701-0800", 
# }
```
## ActiveSupport Tagged Logging

```ruby
Rails.logger.tagged(user.id, user_session.id) do
  Rails.logger.info('UserUpdateJob failed')
end

#
# Outputs:
#
# [1234] [883839] UserUpdateJob failed
```

# How to test this locally

You can setup Fluentd with ruby gems as described on [Fluentd docs](https://docs.fluentd.org/installation/install-by-gem). Once that is running, simply configure your environment with the example above and the logs should appear.
