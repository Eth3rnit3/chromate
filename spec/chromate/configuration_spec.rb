# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chromate::Configuration do
  let(:config) { Chromate::Configuration.new }

  it 'has a default user data dir' do
    expect(config.user_data_dir).to eq File.expand_path('~/.config/google-chrome/Default')
  end

  it 'has a default headless setting' do
    expect(config.headless).to eq true
  end

  it 'has a default xfvb setting' do
    expect(config.xfvb).to eq false
  end

  it 'has a default native control setting' do
    expect(config.native_control).to eq false
  end

  it 'has a default proxy setting' do
    expect(config.proxy).to eq nil
  end

  it 'has default headless args' do
    expect(config.headless_args).to eq Chromate::Configuration::HEADLESS_ARGS
  end

  it 'has default xfvb args' do
    expect(config.xfvb_args).to eq Chromate::Configuration::XVFB_ARGS
  end

  it 'has default disabled features' do
    expect(config.disable_features).to eq Chromate::Configuration::DISABLED_FEATURES
  end

  it 'has default exclude switches' do
    expect(config.exclude_switches).to eq Chromate::Configuration::EXCLUDE_SWITCHES
  end

  it 'can be configured with a block' do
    Chromate.configure do |config|
      config.user_data_dir = 'foo'
    end

    expect(Chromate.configuration.user_data_dir).to eq 'foo'
  end

  describe '#generate_arguments' do
    it 'generates arguments with headless' do
      expect(config.generate_arguments(headless: true)).to include('--headless=new')
    end

    it 'generates arguments with xfvb' do
      expect(config.generate_arguments(xfvb: true)).to include('--disable-gpu')
    end

    it 'generates arguments with proxy' do
      expect(config.generate_arguments(proxy: { host: 'foo', port: 1234 })).to include('--proxy-server=foo:1234')
    end

    it 'generates arguments with disable features' do
      expect(config.generate_arguments(disable_features: ['foo'])).to include('--disable-features=foo')
    end
  end

  context 'when on a linux' do
    before { allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('linux') }

    it 'has default args' do
      expect(config.args).to eq Chromate::Configuration::DEFAULT_ARGS
    end

    describe '#chrome_path' do
      let(:path) { ENV.fetch('CHROME_BIN', '/usr/bin/google-chrome-stable') }

      it 'returns the path to chrome' do
        expect(config.chrome_path).to eq path
      end
    end
  end

  context 'when on a mac' do
    before { allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('darwin') }

    it 'has default args' do
      expect(config.args).to eq Chromate::Configuration::DEFAULT_ARGS + ['--use-angle=metal']
    end

    describe '#chrome_path' do
      let(:path) { ENV.fetch('CHROME_BIN', '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome') }

      it 'returns the path to chrome' do
        expect(config.chrome_path).to eq path
      end
    end
  end

  context 'when on windows' do
    before { allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('mswin') }

    it 'has default args' do
      expect(config.args).to eq Chromate::Configuration::DEFAULT_ARGS
    end

    describe '#chrome_path' do
      let(:path) { ENV.fetch('CHROME_BIN', 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe') }

      it 'returns the path to chrome' do
        expect(config.chrome_path).to eq path
      end
    end
  end

  context 'when on an unsupported platform' do
    before do
      allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('foo')
      allow(ENV).to receive(:[]).with('CHROME_BIN').and_return(nil)
    end

    describe '#chrome_path' do
      it 'raises an exception' do
        expect { config.chrome_path }.to raise_error Chromate::Exceptions::InvalidPlatformError
      end
    end
  end
end
