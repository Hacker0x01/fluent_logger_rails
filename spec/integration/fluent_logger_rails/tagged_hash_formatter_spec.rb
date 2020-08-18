# frozen_string_literal: true
require 'spec_helper'

RSpec.describe FluentLoggerRails::TaggedHashFormatter do
  around(:each) { |example| Time.use_zone('Pacific Time (US & Canada)') { example.run } }
  before { Timecop.freeze('2019-01-08 14:51:39.701-0800') }
  after { Timecop.return }

  subject(:formatter) { described_class.new }

  describe '#datetime_format' do
    before do
      formatter.datetime_format = '%Y-%m-%d'
    end

    it 'formats the date' do
      expect(formatter.call('debug', DateTime.now, nil, 'hi')[:timestamp]).to eq '2019-01-08'
    end
  end

  describe '#parent_key' do
    before do
      formatter.parent_key = :payload
    end

    it 'formats the date' do
      expect(formatter.call(0, DateTime.now, nil, 'hi')).to eq(
        payload: {
          severity: 'DEBUG',
          message: 'hi',
          timestamp: '2019-01-08T14:51:39.700999'
        }
      )
    end
  end

  describe '#add_tags' do
    context 'for a hash' do
      before { formatter.add_tags(host: '127.0.0.1', port: '80')}

      it 'formats the tags in the message' do
        expect(formatter.call(0, DateTime.now, nil, 'hi')).to eq(
          host: '127.0.0.1',
          message: 'hi',
          port: '80',
          severity: 'DEBUG',
          timestamp: '2019-01-08T14:51:39.700999'
        )
      end
    end

    context 'for an array' do
      before { formatter.add_tags(%w[127.0.0.1 80])}

      it 'formats the tags in the message' do
        expect(formatter.call(0, DateTime.now, nil, 'hi')).to eq(
          message: 'hi',
          tags: %w[127.0.0.1 80],
          severity: 'DEBUG',
          timestamp: '2019-01-08T14:51:39.700999'
        )
      end
    end
  end
end
