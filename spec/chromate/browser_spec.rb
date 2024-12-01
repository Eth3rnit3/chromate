# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chromate::Browser do
  subject(:browser) { described_class.new(options) }

  let(:client) { instance_double(Chromate::Client, port: 1234, browser: browser) }
  let(:config) { instance_double(Chromate::Configuration, options: {}, exclude_switches: [], patch?: false) }
  let(:options) do
    {
      chrome_path: '/path/to/chrome',
      user_data_dir: '/tmp/test_user_data',
      headless: true,
      xfvb: false,
      native_control: false,
      record: false
    }
  end
  let(:browser_args) { ['--no-sandbox', '--disable-dev-shm-usage', '--disable-gpu', '--disable-gpu-compositing', '--disable-features=site-per-process'] }

  before do
    allow(Chromate::Client).to receive(:new).and_return(client)
    allow(client).to receive(:start)
    allow(client).to receive(:stop)
    allow(client).to receive(:reconnect)
    allow(client).to receive(:send_message)
    allow(config).to receive(:generate_arguments).and_return(browser_args)
    allow(config).to receive(:args=)
    allow(config).to receive(:user_data_dir=)
    allow(config).to receive(:headless=)
    allow(config).to receive(:xfvb=)
    allow(config).to receive(:native_control=)
    allow(config).to receive(:mouse_controller=)
    allow(config).to receive(:keyboard_controller=)
  end

  describe '#initialize' do
    it 'sets up default options' do
      expect(browser.options).to include(
        chrome_path: '/path/to/chrome',
        headless: true,
        xfvb: false,
        native_control: false,
        record: false
      )
    end
  end

  describe '#started?' do
    let(:binary_double) { instance_double(Chromate::Binary, started?: true) }

    before do
      allow(Chromate::Binary).to receive(:new).with('/path/to/chrome', kind_of(Array)).and_return(binary_double)
      allow(binary_double).to receive(:start)
      allow(binary_double).to receive(:started?).and_return(true)

      browser.start
    end

    it { expect(browser).to be_started }
  end

  describe '#start' do
    let(:binary_double) { instance_double(Chromate::Binary, started?: true) }

    before do
      allow(Chromate::Binary).to receive(:new).with('/path/to/chrome', kind_of(Array)).and_return(binary_double)
      allow(binary_double).to receive(:start)
      allow(binary_double).to receive(:started?).and_return(true)
    end

    it 'initializes and starts the browser components' do
      expect(Chromate::Binary).to receive(:new).with('/path/to/chrome', array_including('--remote-debugging-port=1234'))
      expect(binary_double).to receive(:start)
      expect(client).to receive(:start)
      expect(Chromate::Hardwares::MouseController).to receive(:reset_mouse_position)

      browser.start
    end

    context 'when xfvb is enabled' do
      let(:options) { super().merge(xfvb: true) }
      let(:original_display) { ENV.fetch('DISPLAY', nil) }

      after { ENV['DISPLAY'] = original_display }

      it 'sets DISPLAY environment variable for Mac' do
        ENV['DISPLAY'] = nil
        allow(browser).to receive(:mac?).and_return(true)
        allow(browser).to receive(:linux?).and_return(false)

        browser.start

        expect(ENV.fetch('DISPLAY', nil)).to eq(':0')
      end

      it 'sets DISPLAY environment variable for Linux' do
        ENV['DISPLAY'] = nil
        allow(browser).to receive(:mac?).and_return(false)
        allow(browser).to receive(:linux?).and_return(true)

        browser.start

        expect(ENV.fetch('DISPLAY', nil)).to eq(':99')
      end

      it 'adds display argument to chrome args' do
        ENV['DISPLAY'] = ':1'
        expect(Chromate::Binary).to receive(:new)
          .with('/path/to/chrome', array_including('--display=:1'))

        browser.start
      end
    end

    context 'when recording is enabled' do
      let(:options) { super().merge(record: true) }
      let(:ffmpeg_binary) { instance_double(Chromate::Binary, pid: 12_345) }

      before do
        allow(Chromate::Binary).to receive(:new)
          .with('ffmpeg', kind_of(Array))
          .and_return(ffmpeg_binary)
        allow(ffmpeg_binary).to receive(:start)
      end

      it 'starts video recording' do
        expect(Chromate::Binary).to receive(:new)
          .with('ffmpeg', array_including('-f', 'x11grab'))
        expect(ffmpeg_binary).to receive(:start)

        browser.start
      end
    end
  end

  describe '#stop' do
    let(:binary_double) { instance_double(Chromate::Binary, started?: true) }
    let(:record_pid) { nil }

    before do
      allow(Chromate::Binary).to receive(:new).with('/path/to/chrome', kind_of(Array)).and_return(binary_double)
      allow(binary_double).to receive(:start)
      allow(binary_double).to receive(:stop)

      browser.start
    end

    it 'stops the browser components' do
      browser.stop

      expect(client).to have_received(:stop)
      expect(binary_double).to have_received(:stop)
    end

    it 'cleans up instance variables' do
      browser.stop

      expect(browser.instance_variable_get(:@binary)).to be_nil
      expect(browser.instance_variable_get(:@record_process)).to be_nil
    end

    context 'when recording is active' do
      let(:record_pid) { 12_345 }

      before do
        browser.instance_variable_set(:@record_process, record_pid)
        allow(Process).to receive(:kill)
        allow(Process).to receive(:wait)
      end

      it 'stops the recording process' do
        browser.stop

        expect(Process).to have_received(:kill).with('INT', record_pid)
        expect(Process).to have_received(:wait).with(record_pid)
      end

      context 'when process does not stop gracefully' do
        before do
          allow(Process).to receive(:wait).and_raise(Timeout::Error)
          allow(Process).to receive(:kill).with('KILL', record_pid)
        end

        it 'forces process termination with SIGKILL' do
          browser.stop

          expect(Process).to have_received(:kill).with('KILL', record_pid)
          expect(Process).to have_received(:wait).with(record_pid)
        end
      end
    end
  end

  describe '#native_control?' do
    context 'when native_control is enabled' do
      let(:options) { super().merge(native_control: true) }
      it { expect(browser.native_control?).to be true }
    end

    context 'when native_control is disabled' do
      let(:options) { super().merge(native_control: false) }
      it { expect(browser.native_control?).to be false }
    end
  end

  describe '#stop_and_exit' do
    it 'stops the browser and exits' do
      browser.send(:stop_and_exit)

      expect(browser).to have_received(:stop)
      expect(browser).to have_received(:exit)
    end
  end
end
