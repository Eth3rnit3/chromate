# frozen_string_literal: true

require 'base64'
require 'json'
require 'securerandom'
require 'net/http'
require 'websocket-client-simple'
require_relative 'helpers'
require_relative 'client'
require_relative 'element'
require_relative 'hardwares'
require_relative 'elements/select'
require_relative 'user_agent'
require_relative 'actions/navigate'
require_relative 'actions/screenshot'
require_relative 'actions/dom'

module Chromate
  class Browser
    attr_reader :client, :options

    include Helpers
    include Actions::Navigate
    include Actions::Screenshot
    include Actions::Dom

    def initialize(options = {})
      @options        = config.options.merge(options)
      @chrome_path    = @options.fetch(:chrome_path)
      @user_data_dir  = @options.fetch(:user_data_dir, "/tmp/chromate_#{SecureRandom.hex}")
      @headless       = @options.fetch(:headless)
      @xfvb           = @options.fetch(:xfvb)
      @native_control = @options.fetch(:native_control)
      @record         = @options.fetch(:record, false)
      @process        = nil
      @xfvb_process   = nil
      @record_process = nil
      @client         = nil

      trap('INT') { stop_and_exit }
      trap('TERM') { stop_and_exit }

      at_exit { stop }
    end

    def start
      # start_x_server if @xfvb && (linux? || mac?)
      start_video_recording if @record

      @client = Client.new(self)
      args = [
        @chrome_path,
        "--user-data-dir=#{@user_data_dir}",
        "--lang=#{@options[:lang] || "fr-FR"}"
      ]
      exclude_switches = config.exclude_switches || []
      exclude_switches += @options[:exclude_switches] if @options[:exclude_switches]
      args += config.generate_arguments(**@options)
      args += @options[:options][:args] if @options.dig(:options, :args)
      args << "--user-agent=#{@options[:user_agent] || UserAgent.call}"
      args << "--exclude-switches=#{exclude_switches.join(",")}" if exclude_switches.any?
      args << "--remote-debugging-port=#{@client.port}"

      # Enable Xvfb or XQuartz
      if @xfvb
        if ENV['DISPLAY'].nil?
          ENV['DISPLAY'] = ':0'   if mac? # XQuartz generally uses :0 on Mac
          ENV['DISPLAY'] = ':99'  if linux? # Xvfb generally uses :99 on Linux
        end
        args << "--display=#{ENV.fetch("DISPLAY", nil)}"
      end

      @process = spawn(*args, err: 'chrome_errors.log', out: 'chrome_output.log')
      sleep 2

      @client.start
      self
    end

    def stop
      Process.kill('TERM', @process)        if @process
      Process.kill('TERM', @record_process) if @record_process
      Process.kill('TERM', @xfvb_process)   if @xfvb_process
      @client&.stop
    end

    def native_control?
      @native_control
    end

    private

    def start_x_server
      if linux?
        # Start Xvfb on display :99
        @xfvb_process = spawn('Xvfb :99 -screen 0 1920x1080x24 &')
        ENV['DISPLAY'] = ':99'
        sleep 1 # Wait for Xvfb to start
      elsif mac?
        # Start XQuartz
        system('open -a XQuartz')
        ENV['DISPLAY'] = ':0'
        sleep 2 # Wait for XQuartz to start
      end
    end

    def start_video_recording
      outfile = File.join(Dir.pwd, "output_video_#{Time.now.to_i}.mp4")
      @record_process = spawn("ffmpeg -f x11grab -r 25 -s 1920x1080 -i #{ENV.fetch("DISPLAY", ":99")} -pix_fmt yuv420p -y #{outfile}")
    end

    def stop_and_exit
      puts 'Stopping browser...'
      stop
      exit
    end

    def config
      Chromate.configuration
    end
  end
end
