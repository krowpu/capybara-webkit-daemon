# frozen_string_literal: true

require 'capybara/webkit/daemon/good_option_parser/options'

RSpec.describe Capybara::Webkit::Daemon::GoodOptionParser::Options do
  subject { described_class.new }

  before do
    subject << option
  end

  let(:option) { Capybara::Webkit::Daemon::GoodOptionParser::Option.new '-p', '--port', &-> {} }

  describe '#<<' do
    context 'when argument is not an Option' do
      specify do
        expect { subject << 123 }.to raise_error(
          TypeError,
          "expected option to be a #{Capybara::Webkit::Daemon::GoodOptionParser::Option}",
        )
      end
    end

    context 'when option duplicates' do
      specify do
        expect do
          subject << Capybara::Webkit::Daemon::GoodOptionParser::Option.new('-p', '--port', &-> {})
        end.to raise_error ArgumentError, 'duplicate option'
      end
    end
  end

  describe '#match' do
    it 'matches matching short option key' do
      expect(subject.match('-p')).to eq option
    end

    it 'does not match non-matching short option key' do
      expect(subject.match('-x')).to eq nil
    end

    it 'matches,atching long option key' do
      expect(subject.match('--port')).to eq option
    end

    it 'does not match non-matching long option key' do
      expect(subject.match('--xxx')).to eq nil
    end
  end
end
