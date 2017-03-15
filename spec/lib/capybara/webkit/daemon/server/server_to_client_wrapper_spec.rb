# frozen_string_literal: true

require 'capybara/webkit/daemon/server/server_to_client_wrapper'

RSpec.describe Capybara::Webkit::Daemon::Server::ServerToClientWrapper do
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

  describe '#round' do
    context 'when no messages inserted' do
      it 'transfers data as is' do
        input '123'
        expect(output).to eq '123'
      end
    end
  end

  describe '#message' do
    let(:msg) { 'Hello, World!' }

    it 'inserts message between control characters' do
      subject.message msg
      expect(output).to eq "\x02#{msg}\x03"
    end

    context 'when raw text present' do
      it 'inserts message between control characters in raw data' do
        input '123'
        subject.message msg
        input '456'

        expect(output).to eq "123\x02#{msg}\x03456"
      end
    end
  end

  describe '#message_binary' do
    let(:msg) { "\x00\x01\x02\x03\x04" }

    it 'inserts message with it\'s length between control characters' do
      subject.message_binary msg
      expect(output).to eq "\x01#{msg.size}\x02#{msg}\x03"
    end

    context 'when raw text present' do
      it 'inserts message with it\'s length between control characters in raw data' do
        input '123'
        subject.message_binary msg
        input '456'

        expect(output).to eq "123\x01#{msg.size}\x02#{msg}\x03456"
      end
    end
  end
end
