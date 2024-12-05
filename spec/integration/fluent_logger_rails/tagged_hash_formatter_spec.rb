# frozen_string_literal: true
require 'spec_helper'

RSpec.describe FluentLoggerRails::TaggedHashFormatter, tz: 'Pacific Time (US & Canada)' do
  before { Timecop.freeze('2019-01-08 14:51:39.701-0800') }
  after { Timecop.return }

  subject(:formatter) { described_class.new }

  describe '#datetime_format' do
    before do
      formatter.datetime_format = '%Y-%m-%d'
    end

    it 'formats the date' do
      expect(formatter.call('debug', Time.zone.now, nil, 'hi')[:timestamp]).to eq '2019-01-08'
    end
  end

  describe '#parent_key' do
    before do
      formatter.parent_key = :payload
    end

    it 'formats the date' do
      expect(formatter.call(0, Time.zone.now, nil, 'hi')).to eq(
        payload: {
          severity: 'DEBUG',
          message: 'hi',
          timestamp: '2019-01-08T14:51:39.701000'
        }
      )
    end
  end

  describe '#tagged' do
    let(:tags) { nil }

    context 'nil tag' do
      it 'does not attempt to process the tags' do
        expect(formatter).not_to(receive(:remove_tags).with(anything))

        formatter.tagged(tags) { expect(formatter.current_tags).to(eq({ tags: [] })) }
      end
    end

    context 'with a nested array of nil tags' do
      let(:tags) { [nil] }

      it 'does not attempt to process the tags' do
        expect(formatter).not_to(receive(:remove_tags).with(anything))

        formatter.tagged([tags]) { expect(formatter.current_tags).to(eq({ tags: [] })) }
      end
    end

    context 'with a string tag' do
      let(:tags) { 'tag' }

      it 'adds the tag' do
        formatter.tagged(tags) { expect(formatter.current_tags).to(eq({ tags: [tags] })) }
      end
    end

    context 'with a hash' do
      let(:tags) { { port: 80, host: '127.0.0.1' } }

      it 'adds the tags' do
        formatter.tagged(**tags) do
          expect(formatter.current_tags).to(eq(tags))
        end
      end
    end
  end

  describe '#add_tags' do
    context 'for a hash' do
      before { formatter.add_tags(host: '127.0.0.1', port: '80')}

      it 'formats the tags in the message' do
        expect(formatter.call(0, Time.zone.now, nil, 'hi')).to eq(
          host: '127.0.0.1',
          message: 'hi',
          port: '80',
          severity: 'DEBUG',
          timestamp: '2019-01-08T14:51:39.701000'
        )
      end
    end

    context 'for an array' do
      before { formatter.add_tags(%w[127.0.0.1 80])}

      it 'formats the tags in the message' do
        expect(formatter.call(0, Time.zone.now, nil, 'hi')).to eq(
          message: 'hi',
          tags: %w[127.0.0.1 80],
          severity: 'DEBUG',
          timestamp: '2019-01-08T14:51:39.701000'
        )
      end
    end
  end

  describe '#merge_message_into_payload' do
    subject(:formatter) { described_class.new(true) }

    it 'formats the date' do
      expect(formatter.call(0, Time.zone.now, nil, {'hello': 'world'})).to eq(
        {
          severity: 'DEBUG',
          hello: 'world',
          timestamp: '2019-01-08T14:51:39.701000'
        }
      )
    end
  end
end
