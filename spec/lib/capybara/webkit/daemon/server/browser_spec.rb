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
end
