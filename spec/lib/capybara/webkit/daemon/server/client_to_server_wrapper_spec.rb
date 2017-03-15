# frozen_string_literal: true

require 'capybara/webkit/daemon/server/client_to_server_wrapper'

RSpec.describe Capybara::Webkit::Daemon::Server::ClientToServerWrapper do
  subject { described_class.new source: source, destination: destination }

  let(:source) { StringIO.new }
  let(:destination) { StringIO.new }

  def input(s)
    orig = source.pos
    source.seek 0, IO::SEEK_END
    source.print s
    source.seek orig
    subject.round
  end

  def output
    orig = destination.pos
    destination.seek 0
    result = destination.read
    destination.seek orig
    result
  end

  def command(name, *args)
    "#{name}\n#{args.size}\n#{args.map { |arg| "#{arg.size}\n#{arg}" }.join}"
  end

  describe '#round' do
    context 'when got some messages' do
      let(:msg) { 'Hello, World!' }

      it 'extracts message' do
        expect(subject).to receive(:message).with(msg)

        input command 'Foo'
        input "\x02#{msg}\x03"
        input command 'Bar'
      end

      it 'transfers rest of raw data' do
        input command 'Foo'
        input "\x02#{msg}\x03"
        input command 'Bar'

        expect(output).to eq "#{command 'Foo'}#{command 'Bar'}"
      end
    end

    context 'when got binary message' do
      let(:msg) { "\x00\x01\x02\x03\x04" }

      it 'extracts message' do
        expect(subject).to receive(:message).with(msg)

        input command 'Foo'
        input "\x01#{msg.length}\x02#{msg}\x03"
        input command 'Bar'
      end

      it 'transfers rest of raw data' do
        input command 'Foo'
        input "\x01#{msg.length}\x02#{msg}\x03"
        input command 'Bar'

        expect(output).to eq "#{command 'Foo'}#{command 'Bar'}"
      end
    end

    context 'when no messages got' do
      it 'transfers data as is' do
        input command 'Foo'
        expect(output).to eq command 'Foo'
      end
    end

    context 'when got command with args' do
      let(:args) { %w(qwe rty uiop) }

      it 'transfers data as is' do
        input command 'Foo', *args
        expect(output).to eq command 'Foo', *args
      end
    end

    context 'when got render command' do
      let(:args) { %w(/home/user/screenshot.png 1025 768) }

      it 'does not transfer data' do
        input command 'Render', *args
        expect(output).to be_empty
      end

      it 'calls handler' do
        expect(subject).to receive(:render).with(*args)
        input command 'Render', *args
      end
    end
  end
end
