# frozen_string_literal: true

require 'websocket-client-simple'
require 'chromate/helpers'

module Chromate
  class Client
    include Helpers

    # @return [Array<Proc>]
    def self.listeners
      @@listeners ||= [] # rubocop:disable Style/ClassVars
    end

    attr_reader :port, :ws, :browser

    # @param [Chromate::Browser] browser
    def initialize(browser)
      @browser  = browser
      options   = browser.options
      @port     = options[:port] || find_available_port
    end

    # @return [self]
    def start
      @ws_url = fetch_websocket_debug_url
      @ws = WebSocket::Client::Simple.connect(@ws_url)
      @id = 0
      @callbacks = {}

      client_self = self

      @ws.on :message do |msg|
        message = JSON.parse(msg.data)
        client_self.send(:handle_message, message)

        Client.listeners.each do |listener|
          listener.call(message)
        end
      end

      @ws.on :open do
        Chromate::CLogger.log('Successfully connected to WebSocket', level: :debug)
      end

      @ws.on :error do |e|
        Chromate::CLogger.log("WebSocket error: #{e.message}", level: :error)
      end

      @ws.on :close do |_e|
        Chromate::CLogger.log('WebSocket connection closed', level: :debug)
      end

      sleep 0.2 # Wait for the connection to be established
      client_self.send_message('Target.setDiscoverTargets', { discover: true })

      client_self
    end

    # @return [self]
    def stop
      @ws&.close

      self
    end

    # @param [String] method
    # @param [Hash] params
    # @return [Hash]
    def send_message(method, params = {})
      @id += 1
      message = { id: @id, method: method, params: params }
      Chromate::CLogger.log("Sending WebSocket message: #{message}", level: :debug)

      begin
        @ws.send(message.to_json)
        @callbacks[@id] = Queue.new
        result = @callbacks[@id].pop
        Chromate::CLogger.log("Response received for message #{message[:id]}: #{result}", level: :debug)
        result
      rescue StandardError => e
        Chromate::CLogger.log("Error sending WebSocket message: #{e.message}", level: :error)
        reconnect
        retry
      end
    end

    # @return [self]
    def reconnect
      @ws_url = fetch_websocket_debug_url
      @ws     = WebSocket::Client::Simple.connect(@ws_url)
      Chromate::CLogger.log('Successfully reconnected to WebSocket')

      self
    end

    # Allowing different parts to subscribe to WebSocket messages
    # @yieldparam [Hash] message
    # @return [void]
    def on_message(&block)
      Client.listeners << block
    end

    private

    # @param [Hash] message
    # @return [self]
    def handle_message(message)
      Chromate::CLogger.log("Message received: #{message}", level: :debug)
      return unless message['id'] && @callbacks[message['id']]

      @callbacks[message['id']].push(message['result'])
      @callbacks.delete(message['id'])

      self
    end

    # @return [String]
    def fetch_websocket_debug_url
      uri = URI("http://localhost:#{@port}/json/list")
      response = Net::HTTP.get(uri)
      targets = JSON.parse(response)

      page_target = targets.find { |target| target['type'] == 'page' }

      if page_target
        page_target['webSocketDebuggerUrl']
      else
        create_new_page_target
      end
    end

    # @return [String]
    def create_new_page_target
      uri = URI("http://localhost:#{@port}/json/new")
      response = Net::HTTP.get(uri)
      new_target = JSON.parse(response)

      new_target['webSocketDebuggerUrl']
    end
  end
end
