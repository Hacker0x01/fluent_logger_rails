# frozen_string_literal: true
require 'spec_helper'

RSpec.describe FluentLoggerRails::TaggedLogging do
  subject(:logger) do
    described_class.new(
      ::ActiveSupport::Logger.new($stdout),
      format: :json
    )
  end
  around(:each) { |example| Time.use_zone('Pacific Time (US & Canada)') { example.run } }
  before { Timecop.freeze('2019-01-08 14:51:39.701-0800') }
  after { Timecop.return }

  context '#add aka info, debug, warn, error, fatal' do
    context 'with a string' do
      it 'logs it' do
        expect { logger.info('Hello World!') }.to \
          output(
            {
              'severity': 'INFO',
              'timestamp': '2019-01-08 14:51:39.701-0800',
              'message': 'Hello World!',
            }.to_json,
          ).to_stdout
      end
    end

    context 'with an object' do
      it 'logs it' do
        expect { logger.debug(user_id: 1234) }.to \
          output(
            {
              'severity': 'DEBUG',
              'timestamp': '2019-01-08 14:51:39.701-0800',
              'message': {user_id: 1234},
            }.to_json,
          ).to_stdout
      end
    end

    context 'for other logging levels' do
      it 'logs it' do
        expect { logger.warn('OH NO!') }.to \
          output(
            {
              'severity': 'WARN',
              'timestamp': '2019-01-08 14:51:39.701-0800',
              'message': 'OH NO!',
            }.to_json,
          ).to_stdout
      end
    end
  end

  describe '#tagged' do
    context 'with a hash object' do
      it 'attaches the key/value tag to the output' do
        expect do
          logger.tagged(request_id: '1234', ip: '127.0.0.1') do
            logger.info('This is a cool request tagged with a hash')
          end
        end.to \
          output(
             {
               'severity': 'INFO',
               'timestamp': '2019-01-08 14:51:39.701-0800',
               'message': 'This is a cool request tagged with a hash',
               'request_id': '1234',
               'ip': '127.0.0.1',
             }.to_json,
           ).to_stdout
      end
    end

    context 'with strings' do
      it 'attaches the key/value tag to the output' do
        expect do
          logger.tagged('1234', '127.0.0.1') do
            logger.info('This is a cool request tagged with strings')
          end
        end.to \
          output(
             {
               'severity': 'INFO',
               'timestamp': '2019-01-08 14:51:39.701-0800',
               'message': 'This is a cool request tagged with strings',
               'tags': %w[1234 127.0.0.1],
             }.to_json,
           ).to_stdout
      end
    end
  end
end
