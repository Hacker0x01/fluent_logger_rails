$:.push File.expand_path("../lib", __FILE__)
require "fluent_logger_rails/version"

Gem::Specification.new do |spec|
  spec.name        = 'fluent_logger_rails'
  spec.version     = FluentLoggerRails::VERSION
  spec.date        = '2020-07-14'
  spec.summary     = "A wrapper for fluent-logger gem with support for tagged logging"
  spec.description = "This is a library that wraps the [fluent-logger gem](https://github.com/fluent/fluent-logger-ruby) "\
    "and provides easy integration with your Rails application. This includes log formatters that support "\
    "[Rails tagged logging](https://api.rubyonrails.org/classes/ActiveSupport/TaggedLogging.html) for JSON format "\
    "that can be sent to Fluentd (or really any other logging backend)."
  spec.authors     = ["HackerOne Open Source", "Ben Willis"]
  spec.email       = ["opensource+fluent_logger_rails@hackerone.com", "ben@hackerone.com"]
  spec.homepage      = "https://github.com/Hacker0x01/fluent_logger_rails"

  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.add_dependency('activesupport', '>= 5.0', '< 7')

  spec.add_development_dependency 'rspec', '~> 3.6'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'pry'

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Hacker0x01/fluent_logger_rails"
  spec.metadata["changelog_uri"] = "https://github.com/Hacker0x01/fluent_logger_rails/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
