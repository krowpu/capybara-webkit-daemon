# frozen_string_literal: true

require 'capybara/webkit/daemon/server/session'

require 'capybara/webkit/daemon/server/client'
require 'capybara/webkit/daemon/server/configuration'

RSpec.describe Capybara::Webkit::Daemon::Server::Session do
  subject { described_class.new client, configuration: configuration }

  let(:client) { Capybara::Webkit::Daemon::Server::Client.new client_socket }
  let(:configuration) { Capybara::Webkit::Daemon::Server::Configuration.new }

  let(:client_socket) { StringIO.new }

  describe '#client' do
    it 'returns original client' do
      expect(subject.client).to equal client
    end
  end

  describe '#configuration' do
    it 'returns original configuration' do
      expect(subject.configuration).to equal configuration
    end
  end

  describe '#browser' do
    it 'creates browser with original configuration' do
      expect(subject.browser.configuration).to equal configuration
    end
  end

  describe '#link' do
    it 'creates link with original client' do
      expect(subject.link.client).to equal client
    end

    it 'creates link with created browser' do
      expect(subject.link.browser).to equal subject.browser
    end
  end
end
