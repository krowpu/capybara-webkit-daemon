# frozen_string_literal: true

require 'capybara/webkit/daemon/good_option_parser/option'

RSpec.describe Capybara::Webkit::Daemon::GoodOptionParser::Option do
  subject { described_class.new short, long, description, &block }

  let(:short) { '-p' }
  let(:long) { '--port' }
  let(:description) { 'Run on the specified port' }

  let :block do
    lambda do |config, arg|
      arg = arg.()
      raise ArgumentError, 'invalid port format' unless arg =~ /\A\d+\z/
      config.merge port: arg.to_i
    end
  end

  describe '#initialize' do
    context 'when there are no option keys' do
      let(:short) { nil }
      let(:long) { nil }

      specify do
        expect { subject }.to raise_error ArgumentError, 'no option keys'
      end
    end

    context 'when short option key is invalid' do
      let(:short) { '-qwe' }

      specify do
        expect { subject }.to raise_error ArgumentError, 'invalid short option key'
      end
    end

    context 'when long option key is invalid' do
      let(:long) { '--' }

      specify do
        expect { subject }.to raise_error ArgumentError, 'invalid long option key'
      end
    end

    context 'when description is not a String' do
      let(:description) { 123 }

      specify do
        expect { subject }.to raise_error TypeError, 'expected description to be a String'
      end
    end

    context 'when no block given' do
      let(:block) { nil }

      specify do
        expect { subject }.to raise_error TypeError, 'expected block to be a Proc'
      end
    end
  end

  describe '#short' do
    it 'is frozen' do
      expect(subject.short).to be_frozen
    end

    it 'equals original value' do
      expect(subject.short).to eq short
    end

    it 'dups' do
      expect(subject.short).not_to equal short
    end
  end

  describe '#long' do
    it 'is frozen' do
      expect(subject.long).to be_frozen
    end

    it 'equals original value' do
      expect(subject.long).to eq long
    end

    it 'dups' do
      expect(subject.long).not_to equal long
    end
  end

  describe '#description' do
    it 'is frozen' do
      expect(subject.description).to be_frozen
    end

    it 'equals original value' do
      expect(subject.description).to eq description
    end

    it 'dups' do
      expect(subject.description).not_to equal description
    end
  end

  describe '#block' do
    it 'equals original value' do
      expect(subject.block).to eq block
    end
  end
end
