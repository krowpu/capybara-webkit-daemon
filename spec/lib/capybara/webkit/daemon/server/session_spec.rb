# frozen_string_literal: true

require 'capybara/webkit/daemon/server/session'

require 'capybara/webkit/daemon/server/client'
require 'capybara/webkit/daemon/server/configuration'

require 'timeout'
require 'timecop'

RSpec.describe Capybara::Webkit::Daemon::Server::Session do
  subject { described_class.new client, configuration: configuration }

  let(:client) { Capybara::Webkit::Daemon::Server::Client.new client_socket }
  let(:configuration) { Capybara::Webkit::Daemon::Server::Configuration.new }

  let(:client_socket) { StringIO.new }

  describe '#active?' do
    it 'returns true' do
      expect(subject).to be_active
    end

    context 'when session has been closed' do
      before do
        subject.close
      end

      it 'returns false' do
        expect(subject).not_to be_active
      end
    end
  end

  describe '#started_at' do
    it 'returns session start time' do
      started_at = Time.at Time.now.to_f * rand

      Timecop.freeze started_at do
        subject
      end

      expect(subject.started_at).to eq started_at
    end
  end

  describe '#duration' do
    it 'returns session duration' do
      started_at = Time.at Time.now.to_f * rand
      now = started_at + rand(10 * 365 * 24 * 60 * 60) # about 10 years

      Timecop.freeze started_at do
        subject
      end

      Timecop.freeze now do
        expect(subject.duration).to eq now - started_at
      end
    end

    context 'when session has been closed' do
      it 'returns session finish time' do
        started_at = Time.at Time.now.to_f * rand
        finished_at = started_at + rand(10 * 365 * 24 * 60 * 60) # about 10 years

        Timecop.freeze started_at do
          subject
        end

        Timecop.freeze finished_at do
          subject.close
        end

        expect(subject.duration).to eq finished_at - started_at
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

  describe '#close_if_time_exceeded' do
    pending 'is called during session initialization'

    it 'closes session after 5 minutes' do
      now = Time.now
      started_at = Time.at now - 5 * 60 # 5 minutes ago

      Timecop.freeze started_at do
        subject
      end

      Timecop.travel now do
        subject.close_if_time_exceeded.join
        expect(subject).not_to be_active
      end
    end

    it 'does not wait for or close inactive session' do
      now = Time.now
      started_at = Time.at now - 5 * 60 # 5 minutes ago

      Timecop.freeze started_at do
        subject.close
      end

      Timecop.travel now do
        expect do
          Timeout.timeout 15 do
            subject.close_if_time_exceeded.join
          end
        end.not_to raise_error
      end
    end
  end

  describe '#client' do
    it 'returns original client' do
      expect(subject.client).to equal client
    end

    context 'when session has been closed' do
      before do
        subject.close
      end

      it 'returns nil' do
        expect(subject.client).to eq nil
      end
    end
  end

  describe '#configuration' do
    it 'returns original configuration' do
      expect(subject.configuration).to equal configuration
    end
  end

  describe '#browser' do
    it 'creates active browser' do
      expect(subject.browser).to be_active
    end

    it 'creates browser with original configuration' do
      expect(subject.browser.configuration).to equal configuration
    end

    context 'when session has been closed' do
      let!(:browser) { subject.browser }

      before do
        subject.close
      end

      it 'closes browser' do
        expect(browser).not_to be_active
      end

      it 'returns nil' do
        expect(subject.browser).to eq nil
      end
    end
  end

  describe '#link' do
    it 'creates link with original client' do
      expect(subject.link.client).to equal client
    end

    it 'creates link with created browser' do
      expect(subject.link.browser).to equal subject.browser
    end

    context 'when session has been closed' do
      before do
        subject.close
      end

      it 'returns nil' do
        expect(subject.link).to eq nil
      end
    end
  end
end
