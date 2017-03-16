# frozen_string_literal: true

require 'capybara/webkit/daemon/server/connection'

require 'capybara/webkit/daemon/server/configuration'

RSpec.describe Capybara::Webkit::Daemon::Server::Connection do
  subject { described_class.new configuration: configuration }

  let(:configuration) { Capybara::Webkit::Daemon::Server::Configuration.new }

  it { is_expected.not_to respond_to :port }
  it { is_expected.not_to respond_to :pid  }

  describe '#active?' do
    it 'returns true' do
      expect(subject).to be_active
    end

    context 'when connection has been closed' do
      before do
        subject.close
      end

      it 'returns false' do
        expect(subject).not_to be_active
      end
    end
  end

  describe '#close' do
    before do
      subject.close
    end

    context 'when called twice' do
      it 'raises exception' do
        expect { subject.close }.to raise_error RuntimeError, 'connection already closed'
      end
    end
  end

  describe '#configuration' do
    it 'returns original configuration' do
      expect(subject.configuration).to equal configuration
    end
  end

  describe '#server' do
    it 'creates active server' do
      expect(subject.server).to be_active
    end

    it 'creates server with original configuration' do
      expect(subject.server.configuration).to equal configuration
    end

    context 'when connection has been closed' do
      let!(:server) { subject.server }

      before do
        subject.close
      end

      it 'closes server' do
        expect(server).not_to be_active
      end

      it 'returns nil' do
        expect(subject.server).to eq nil
      end
    end
  end

  describe '#socket' do
    it 'creates socket' do
      expect(subject.socket).to be_a TCPSocket
    end

    it 'returns working socket' do
      subject.socket.write "Version\n0\n"
      subject.socket.flush

      expect(subject.socket.gets).to eq "ok\n"
    end

    context 'when connection has been closed' do
      let!(:socket) { subject.socket }

      before do
        subject.close
      end

      it 'closes socket' do
        expect(socket).to be_closed
      end

      it 'returns nil' do
        expect(subject.socket).to eq nil
      end
    end
  end

  describe '#puts, #gets' do
    it 'really connects with server' do
      subject.puts "Version\n0"
      expect(subject.gets).to eq "ok\n"
    end
  end

  describe '#print, #read' do
    it 'really connects with server' do
      subject.print "Version\n0\n"
      expect(subject.read(3)).to eq "ok\n"
    end
  end
end
