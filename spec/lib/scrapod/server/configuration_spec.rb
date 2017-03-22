# frozen_string_literal: true

require 'scrapod/server/configuration'

RSpec.describe Scrapod::Server::Configuration do
  subject { described_class.new options }

  let(:options) { {} }

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

  it 'is initialized with default options' do
    expect(subject.to_h).to eq described_class::DEFAULTS
  end

  context 'when no options presents' do
    subject { described_class.new }

    it 'is initialized with default options' do
      expect(subject.to_h).to eq described_class::DEFAULTS
    end
  end

  describe '#==' do
    it 'returns true for similar configurations' do
      expect(subject).to eq described_class.new options
    end

    it 'returns false for different configuration' do
      expect(subject).not_to eq described_class.new options.merge help: !options[:help]
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
end
