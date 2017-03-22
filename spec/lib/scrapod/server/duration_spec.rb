# frozen_string_literal: true

require 'scrapod/server/duration'

RSpec.describe Scrapod::Server::Duration do
  subject { described_class.new s }

  let(:s) { '2d7h15m53s' }

  context 'for invalid duration type' do
    let(:s) { 123 }

    specify do
      expect { subject }.to raise_error TypeError
    end
  end

  context 'for empty duration string' do
    let(:s) { '' }

    specify do
      expect { subject }.to raise_error ArgumentError
    end
  end

  context 'for invalid duration string format' do
    let(:s) { 'qwe' }

    specify do
      expect { subject }.to raise_error ArgumentError
    end
  end

  describe '#to_secs' do
    it 'returns valid total number of seconds' do
      expect(subject.to_secs).to eq \
        (2 * 24 * 60 * 60) + (7 * 60 * 60) + (15 * 60) + 53
    end

    context 'when only days present' do
      let(:s) { '3d' }

      it 'returns valid total number of seconds' do
        expect(subject.to_secs).to eq 3 * 24 * 60 * 60
      end
    end

    context 'when only hours present' do
      let(:s) { '3h' }

      it 'returns valid total number of seconds' do
        expect(subject.to_secs).to eq 3 * 60 * 60
      end
    end

    context 'when only minutes present' do
      let(:s) { '3m' }

      it 'returns valid total number of seconds' do
        expect(subject.to_secs).to eq 3 * 60
      end
    end

    context 'when only seconds present' do
      let(:s) { '3s' }

      it 'returns valid total number of seconds' do
        expect(subject.to_secs).to eq 3
      end
    end

    context 'when too many hours present' do
      let(:s) { '24h' }

      specify do
        expect { subject.to_secs }.to raise_error ArgumentError
      end
    end

    context 'when too many minutes present' do
      let(:s) { '60m' }

      specify do
        expect { subject.to_secs }.to raise_error ArgumentError
      end
    end

    context 'when too many seconds present' do
      let(:s) { '60s' }

      specify do
        expect { subject.to_secs }.to raise_error ArgumentError
      end
    end
  end
end
