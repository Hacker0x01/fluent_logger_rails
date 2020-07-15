# frozen_string_literal: true
require 'spec_helper'

RSpec.describe FluentLoggerRails::Logger do
  class MockFluentLogger
    attr_accessor :logs
    def initialize
      @logs = []
    end

    def post(tag, map)
      logs << [tag, map.dup]
    end

    def clear
      logs.clear
    end

    def close; end
  end

  subject(:logger) do
    FluentLoggerRails::Logger.new(fluent_logger, path: 'test.rails', level: :info).tap do |logger|
      logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end
  end
  let(:fluent_logger) { MockFluentLogger.new }

  context 'log_level' do
    it 'logs a thing' do
      logger.info 'hello world'
      expect(fluent_logger.logs).to match [['test.rails', { message: "hello world\n" }]]
    end

    context 'when the log level is too low' do
      it 'logs a thing' do
        logger.debug 'hello world'
        expect(fluent_logger.logs).to be_empty
      end
    end
  end
end
