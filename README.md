# Fluent Logger Rails

This is a library that wraps the [fluent-logger gem](https://github.com/fluent/fluent-logger-ruby) and provides easy integration with your Rails application. This includes a log formatter that supports [Rails tagged logging](https://api.rubyonrails.org/classes/ActiveSupport/TaggedLogging.html) so your output JSON format that can be sent to Fluentd (or really any other logging backend).

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
  # if you are using tagged logging, you need a formatter that supports it
  config.logger.formatter = FluentLoggerRails::TaggedHashFormatter.new
end
```

## Formatter Configuration

This gem includes a formatter that supports [Rails tagged logging](https://api.rubyonrails.org/classes/ActiveSupport/TaggedLogging.html).

### Hash aka JSON logger formatter

This is a JSON formatter that supports tagged logging.
```ruby
config.logger.formatter = FluentLoggerRails::TaggedHashFormatter.new
config.logger.formatter.datetime_format = '%Y-%m-%d %H:%M:%S.%3N%z'
config.logger.formatter.parent_key = 'payload'
```

### Standard Rails Tagged Logger aka default logger format

The standard Rails tagged logger works as well for standard output.
```ruby
ActiveSupport::TaggedLogging.new(config.logger)
```

# Examples

## Hash formatter with tagged Logging
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

## Hash formatter with hash tagged Logging

```ruby
Rails.logger.tagged(user_id: user.id, session_id: user_session.id) do
  Rails.logger.info(message: 'UserUpdateJob failed', args: args)
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

## Standard Rails formatter with tagged Logger

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

# Related Projects

 - https://github.com/fluent/fluent-logger-ruby
 - https://github.com/actindi/act-fluent-logger-rails
