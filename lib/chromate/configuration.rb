# frozen_string_literal: true

require_relative 'helpers'
require_relative 'exceptions'
require_relative 'c_logger'

module Chromate
  class Configuration
    include Helpers
    include Exceptions
    DEFAULT_ARGS = [
      '--no-first-run',
      '--no-default-browser-check',
      '--disable-blink-features=AutomationControlled',
      '--disable-extensions',
      '--disable-infobars',
      '--no-sandbox',
      '--disable-popup-blocking',
      '--ignore-certificate-errors',
      '--disable-gpu',
      '--disable-dev-shm-usage',
      '--window-size=1920,1080', # TODO: Make this automatic
      '--hide-crash-restore-bubble'
    ].freeze
    HEADLESS_ARGS = [
      '--headless=new',
      '--window-position=2400,2400'
    ].freeze
    XVFB_ARGS = [
      '--window-position=0,0'
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

    def self.config
      @config ||= Configuration.new
    end

    def self.configure
      yield(config)
    end

    def config
      self.class.config
    end

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

    def generate_arguments(headless: @headless, xfvb: @xfvb, proxy: @proxy, disable_features: @disable_features, **_args)
      dynamic_args = []

      dynamic_args += @headless_args  if headless
      dynamic_args += @xfvb_args      if xfvb
      dynamic_args << "--proxy-server=#{proxy[:host]}:#{proxy[:port]}" if proxy && proxy[:host] && proxy[:port]
      dynamic_args << "--disable-features=#{disable_features.join(",")}" unless disable_features.empty?

      @args + dynamic_args
    end

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
