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
end
