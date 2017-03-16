# frozen_string_literal: true

require 'capybara/webkit/daemon/server/browser'

require 'capybara/webkit/daemon/server/configuration'

RSpec.describe Capybara::Webkit::Daemon::Server::Browser do
  subject { described_class.new configuration: configuration }

  let(:configuration) { Capybara::Webkit::Daemon::Server::Configuration.new }

  it 'provides interface for connection' do
    expect { subject.version.lines.first }.not_to raise_error
  end

  describe '#active?' do
    it 'returns true' do
      expect(subject).to be_active
    end

    context 'when browser has been closed' do
      before do
        subject.close
      end

      it 'returns false' do
        expect(subject).not_to be_active
      end
    end
  end

  describe '#close' do
    context 'when called twice' do
      before do
        subject.close
      end

      it 'does not raise exception' do
        expect { subject.close }.not_to raise_error
      end
    end
  end

  describe '#configuration' do
    it 'returns original configuration' do
      expect(subject.configuration).to equal configuration
    end
  end

  describe '#connection' do
    it 'creates connection with original configuration' do
      expect(subject.connection.configuration).to equal configuration
    end

    it 'returns working connection' do
      subject.connection.print "Version\n0\n"
      expect(subject.connection.gets).to eq "ok\n"
    end

    context 'when browser has been closed' do
      let!(:connection) { subject.connection }

      before do
        subject.close
      end

      it 'closes connection' do
        expect(connection).not_to be_active
      end

      it 'returns nil' do
        expect(subject.connection).to eq nil
      end
    end
  end
end
