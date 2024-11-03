# frozen_string_literal: true

require 'websocket-client-simple'
require 'chromate/helpers'

module Chromate
  class Client
    include Helpers

    def self.listeners
      @@listeners ||= [] # rubocop:disable Style/ClassVars
    end

    attr_reader :port, :ws, :browser

    def initialize(browser)
      @browser = browser
      options = browser.options
      @port = options[:port] || find_available_port
    end

    def start
      @ws_url = fetch_websocket_debug_url
      @ws = WebSocket::Client::Simple.connect(@ws_url)
      @id = 0
      @callbacks = {}

      client_self = self

      @ws.on :message do |msg|
        message = JSON.parse(msg.data)
        client_self.handle_message(message)

        Client.listeners.each do |listener|
          listener.call(message)
        end
      end

      @ws.on :open do
        puts "Connexion WebSocket établie avec #{@ws_url}"
      end

      @ws.on :error do |e|
        puts "Erreur WebSocket : #{e.message}"
      end

      @ws.on :close do |_e|
        puts 'Connexion WebSocket fermée'
      end

      sleep 0.2
      client_self.send_message('Target.setDiscoverTargets', { discover: true })
      client_self
    end

    def stop
      @ws&.close
    end

    def send_message(method, params = {})
      @id += 1
      message = { id: @id, method: method, params: params }
      puts "Envoi du message : #{message}"

      begin
        @ws.send(message.to_json)
        @callbacks[@id] = Queue.new
        result = @callbacks[@id].pop
        puts "Réponse reçue pour le message #{message[:id]} : #{result}"
        result
      rescue StandardError => e
        puts "Erreur WebSocket lors de l'envoi du message : #{e.message}"
        reconnect
        retry
      end
    end

    def reconnect
      @ws_url = fetch_websocket_debug_url
      @ws     = WebSocket::Client::Simple.connect(@ws_url)
      puts 'Reconnexion WebSocket réussie'
    end

    def handle_message(message)
      puts "Message reçu : #{message}"
      return unless message['id'] && @callbacks[message['id']]

      @callbacks[message['id']].push(message['result'])
      @callbacks.delete(message['id'])
    end

    # Allowing different parts to subscribe to WebSocket messages
    def on_message(&block)
      Client.listeners << block
    end

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

    def create_new_page_target
      # Créer une nouvelle page
      uri = URI("http://localhost:#{@port}/json/new")
      response = Net::HTTP.get(uri)
      new_target = JSON.parse(response)

      new_target['webSocketDebuggerUrl']
    end
  end
end
