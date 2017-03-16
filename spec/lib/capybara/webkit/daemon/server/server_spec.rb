# frozen_string_literal: true

require 'capybara/webkit/daemon/server/server'

require 'capybara/webkit/daemon/server/configuration'

RSpec.describe Capybara::Webkit::Daemon::Server::Server do
  subject { described_class.new configuration: configuration }

  let(:configuration) { Capybara::Webkit::Daemon::Server::Configuration.new }

  describe '#active?' do
    it 'returns true' do
      expect(subject).to be_active
    end

    context 'when server has been closed' do
      before do
        subject.close
      end

      it 'returns false' do
        expect(subject).not_to be_active
      end
    end
  end

  describe '#close' do
    let!(:pid) { subject.pid }

    before do
      subject.close
    end

    it 'actually kills server process' do
      expect(`ps -p #{pid}`.lines.count).to eq 1
    end

    context 'when called twice' do
      it 'raises exception' do
        expect { subject.close }.to raise_error RuntimeError, 'server already closed'
      end
    end
  end

  describe '#configuration' do
    it 'returns original configuration' do
      expect(subject.configuration).to equal configuration
    end
  end

  describe '#port' do
    it 'returns valid port number' do
      expect(subject.port).to be_between 1024, 65_535
    end

    it 'returns running server port number' do
      conn = TCPSocket.new '127.0.0.1', subject.port

      conn.write "Version\n0\n"
      conn.flush

      expect(conn.gets).to eq "ok\n"

      conn.close
    end

    context 'when server has been closed' do
      before do
        subject.close
      end

      it 'returns nil' do
        expect(subject.port).to eq nil
      end
    end
  end

  describe '#pid' do
    it 'returns real process PID' do
      expect(Process.kill(0, subject.pid)).to eq 1
    end

    it 'returns running server PID' do
      expect(`ps -p #{subject.pid}`.lines.last.split.last).to eq 'webkit_server'
    end

    context 'when server has been closed' do
      before do
        subject.close
      end

      it 'returns nil' do
        expect(subject.pid).to eq nil
      end
    end
  end
end
