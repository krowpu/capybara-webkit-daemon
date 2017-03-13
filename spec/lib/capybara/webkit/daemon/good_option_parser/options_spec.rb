# frozen_string_literal: true

require 'capybara/webkit/daemon/good_option_parser/options'

RSpec.describe Capybara::Webkit::Daemon::GoodOptionParser::Options do
  subject { described_class.new }

  before do
    subject << option_short_only
    subject << option
    subject << option_long_only
    subject << option2
    subject << option_without_description
  end

  let :option do
    Capybara::Webkit::Daemon::GoodOptionParser::Option.new(
      '-b',
      '--binding',
      'Bind to the specified IP',
      &-> {}
    )
  end

  let :option2 do
    Capybara::Webkit::Daemon::GoodOptionParser::Option.new(
      '-p',
      '--port',
      'Run on the specified port',
      &-> {}
    )
  end

  let :option_short_only do
    Capybara::Webkit::Daemon::GoodOptionParser::Option.new(
      '-a',
      nil,
      'Foo',
      &-> {}
    )
  end

  let :option_long_only do
    Capybara::Webkit::Daemon::GoodOptionParser::Option.new(
      nil,
      '--aaa',
      'Bar',
      &-> {}
    )
  end

  let :option_without_description do
    Capybara::Webkit::Daemon::GoodOptionParser::Option.new(
      '-c',
      '--ccc',
      &-> {}
    )
  end

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
      expect(subject.match('-p')).to eq option2
    end

    it 'does not match non-matching short option key' do
      expect(subject.match('-x')).to eq nil
    end

    it 'matches,atching long option key' do
      expect(subject.match('--binding')).to eq option
    end

    it 'does not match non-matching long option key' do
      expect(subject.match('--xxx')).to eq nil
    end
  end

  describe '#description' do
    it 'returns proper description' do
      expect(subject.description).to eq <<-END.gsub(/^\s*/, ' ' * 4)
        -a               Foo
        -b, --binding    Bind to the specified IP
            --aaa        Bar
        -p, --port       Run on the specified port
        -c, --ccc
      END
    end
  end
end
