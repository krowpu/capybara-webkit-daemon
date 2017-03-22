# frozen_string_literal: true

require 'scrapod/server/configuration'

RSpec.describe Scrapod::Server::Configuration do
  subject { described_class.new }

  it { is_expected.to respond_to :help  }
  it { is_expected.to respond_to :help= }

  it { is_expected.to respond_to :config_file  }
  it { is_expected.to respond_to :config_file= }

  it { is_expected.to respond_to :pid_file  }
  it { is_expected.to respond_to :pid_file= }

  it { is_expected.to respond_to :log_file  }
  it { is_expected.to respond_to :log_file= }

  it { is_expected.to respond_to :log_level  }
  it { is_expected.to respond_to :log_level= }

  it { is_expected.to respond_to :binding  }
  it { is_expected.to respond_to :binding= }

  it { is_expected.to respond_to :port  }
  it { is_expected.to respond_to :port= }

  it { is_expected.to respond_to :display  }
  it { is_expected.to respond_to :display= }

  it { is_expected.to respond_to :max_session_duration  }
  it { is_expected.to respond_to :max_session_duration= }

  it { is_expected.to respond_to :redis_url  }
  it { is_expected.to respond_to :redis_url= }

  describe '#help' do
    it 'is false by default' do
      expect(subject.help).to eq false
    end
  end

  describe '#help=' do
    it 'converts false value to boolean' do
      subject.help = nil
      expect(subject.help).to eq false
    end

    it 'converts true value to boolean' do
      subject.help = 123
      expect(subject.help).to eq true
    end
  end

  describe '#config_file' do
    it 'is nil by default' do
      expect(subject.config_file).to eq nil
    end
  end
end
