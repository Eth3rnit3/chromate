# frozen_string_literal: true

require_relative 'helpers'
require_relative 'exceptions'
require_relative 'c_logger'

module Chromate
  class Configuration
    include Helpers
    include Exceptions
    DEFAULT_ARGS = [
      '--no-first-run', # Skip the first run wizard
      '--no-default-browser-check', # Disable the default browser check
      '--disable-blink-features=AutomationControlled', # Disable the AutomationControlled feature
      '--disable-extensions', # Disable extensions
      '--disable-infobars', # Disable the infobar that asks if you want to install Chrome
      '--no-sandbox', # Required for chrome devtools to work
      '--test-type', # Remove the not allowed message for --no-sandbox flag
      '--disable-dev-shm-usage', # Disable /dev/shm usage
      '--disable-gpu', # Disable the GPU
      '--disable-popup-blocking', # Disable popup blocking
      '--ignore-certificate-errors', # Ignore certificate errors
      '--window-size=1920,1080', # TODO: Make this automatic
      '--hide-crash-restore-bubble' # Hide the crash restore bubble
    ].freeze
    HEADLESS_ARGS = [
      '--headless=new',
      '--window-position=2400,2400'
    ].freeze
    XVFB_ARGS = [
      '--window-position=0,0',
      '--start-fullscreen'
    ].freeze
    DISABLED_FEATURES = %w[
      Translate
      OptimizationHints
      MediaRouter
      DialMediaRouteProvider
      CalculateNativeWinOcclusion
      InterestFeedContentSuggestions
      CertificateTransparencyComponentUpdater
      AutofillServerCommunication
      PrivacySandboxSettings4
      AutomationControlled
    ].freeze
    EXCLUDE_SWITCHES = %w[
      enable-automation
    ].freeze

    attr_accessor :user_data_dir, :headless, :xfvb, :native_control, :args, :headless_args, :xfvb_args, :exclude_switches, :proxy,
                  :disable_features

    def initialize
      @user_data_dir      = File.expand_path('~/.config/google-chrome/Default')
      @headless           = true
      @xfvb               = false
      @native_control     = false
      @proxy              = nil
      @args               = [] + DEFAULT_ARGS
      @headless_args      = [] + HEADLESS_ARGS
      @xfvb_args          = [] + XVFB_ARGS
      @disable_features   = [] + DISABLED_FEATURES
      @exclude_switches   = [] + EXCLUDE_SWITCHES

      @args << '--use-angle=metal' if mac?
    end

    # @return [Chromate::Configuration]
    def self.config
      @config ||= Configuration.new
    end

    # @yield [Chromate::Configuration]
    def self.configure
      yield(config)
    end

    # @return [Chromate::Configuration]
    def config
      self.class.config
    end

    # @return [String]
    def chrome_path
      return ENV['CHROME_BIN'] if ENV['CHROME_BIN']

      if mac?
        '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
      elsif linux?
        '/usr/bin/google-chrome-stable'
      elsif windows?
        'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
      else
        raise Exceptions::InvalidPlatformError, 'Unsupported platform'
      end
    end

    # @option [Boolean] headless
    # @option [Boolean] xfvb
    # @option [Hash] proxy
    # @option [Array<String>] disable_features
    def generate_arguments(headless: @headless, xfvb: @xfvb, proxy: @proxy, disable_features: @disable_features, **_args)
      dynamic_args = []

      dynamic_args += @headless_args  if headless
      dynamic_args += @xfvb_args      if xfvb
      dynamic_args << "--proxy-server=#{proxy[:host]}:#{proxy[:port]}" if proxy && proxy[:host] && proxy[:port]
      dynamic_args << "--disable-features=#{disable_features.join(",")}" unless disable_features.empty?

      @args + dynamic_args
    end

    # @return [Hash]
    def options
      {
        chrome_path: chrome_path,
        user_data_dir: @user_data_dir,
        headless: @headless,
        xfvb: @xfvb,
        native_control: @native_control,
        args: @args,
        headless_args: @headless_args,
        xfvb_args: @xfvb_args,
        exclude_switches: @exclude_switches,
        proxy: @proxy,
        disable_features: @disable_features
      }
    end
  end
end
