# frozen_string_literal: true

require 'capybara/webkit/daemon/server/browser'

require 'capybara/webkit/daemon/server/configuration'

RSpec.describe Capybara::Webkit::Daemon::Server::Browser do
  subject { described_class.new configuration: configuration }

  let(:configuration) { Capybara::Webkit::Daemon::Server::Configuration.new }

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

      it 'raises exception' do
        expect { subject.close }.to raise_error RuntimeError, 'browser already closed'
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

    context 'when browser has been closed' do
      before do
        subject.close
      end

      it 'returns nil' do
        expect(subject.connection).to eq nil
      end
    end
  end
end
