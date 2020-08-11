# frozen_string_literal: true
require 'spec_helper'

RSpec.describe FluentLoggerRails::Logger do
  around(:each) { |example| Time.use_zone('Pacific Time (US & Canada)') { example.run } }
  before { Timecop.freeze('2019-01-08 14:51:39.701-0800') }
  after { Timecop.return }

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
    FluentLoggerRails::Logger.new(fluent_logger, path: 'test.rails', level: :info)
  end
  let(:fluent_logger) { MockFluentLogger.new }

  context 'log_level' do
    before do
      logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
      logger.formatter.datetime_format = '%Y-%m-%d %H:%M:%S.%3N%z'
    end

    it 'logs a thing' do
      logger.info 'hello world'
      expect(fluent_logger.logs).to match [['test.rails', "hello world\n"]]
    end

    context 'when the log level is too low' do
      it 'logs a thing' do
        logger.debug 'hello world'
        expect(fluent_logger.logs).to be_empty
      end
    end
  end

  context 'with a json formatter' do
    before do
      logger.formatter = JsonFormatter.new
      logger.formatter.datetime_format = '%Y-%m-%d %H:%M:%S.%3N%z'
    end

    context '#add aka info, debug, warn, error, fatal' do
      context 'with a string' do
        it 'logs it' do
          logger.info('Hello World!')

          expect(fluent_logger.logs[0][1]).to eq(
            {
              'severity': 'INFO',
              'timestamp': '2019-01-08 14:51:39.701-0800',
              'message': 'Hello World!',
            }.to_json,
          )
        end
      end

      context 'with a hash' do
        it 'logs it' do
          logger.warn(user_id: 1234)

          expect(fluent_logger.logs[0][1]).to eq(
            {
                'severity': 'WARN',
                'timestamp': '2019-01-08 14:51:39.701-0800',
                'message': {
                  user_id: 1234
                },
            }.to_json,
          )
        end
      end

      context 'for other logging levels' do
        it 'logs it' do
          logger.warn('OH NO!')

          expect(fluent_logger.logs[0][1]).to eq(
            {
                'severity': 'WARN',
                'timestamp': '2019-01-08 14:51:39.701-0800',
                'message': 'OH NO!',
            }.to_json,
          )
        end
      end
    end

    describe '#tagged' do
      context 'with a hash object' do
        it 'attaches the key/value tag to the output' do
          logger.tagged(request_id: '1234', ip: '127.0.0.1') do
            logger.info('This is a cool request tagged with a hash')
          end

          expect(fluent_logger.logs[0][1]).to eq(
            {
              'severity': 'INFO',
              'timestamp': '2019-01-08 14:51:39.701-0800',
              'message': 'This is a cool request tagged with a hash',
              'request_id': '1234',
              'ip': '127.0.0.1',
            }.to_json,
          )
        end
      end

      context 'with strings' do
        it 'attaches the key/value tag to the output' do
          logger.tagged('1234', '127.0.0.1') do
            logger.info('This is a cool request tagged with strings')
          end

          expect(fluent_logger.logs[0][1]).to eq(
            {
              'severity': 'INFO',
              'timestamp': '2019-01-08 14:51:39.701-0800',
              'message': 'This is a cool request tagged with strings',
              'tags': %w[1234 127.0.0.1],
            }.to_json
          )
        end
      end
    end
  end
end