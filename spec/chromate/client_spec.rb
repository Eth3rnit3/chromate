# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chromate::Client do
  subject(:client) { described_class.new(browser) }

  let(:browser) { instance_double(Chromate::Browser, options: { port: 8627 }) }

  describe '#initialize' do
    it 'sets the browser' do
      expect(client.browser).to eq(browser)
    end

    it 'sets the port' do
      expect(client.port).to eq(8627)
    end

    context 'when the port is not provided' do
      let(:browser) { instance_double(Chromate::Browser, options: {}) }

      it 'finds an available port' do
        expect(client.port).to be_a(Integer)
      end
    end
  end

  describe '#start' do
    let(:ws) { instance_double(WebSocket::Client::Simple::Client) }

    before do
      allow(WebSocket::Client::Simple).to receive(:connect).with('ws://localhost:9222/devtools/browser/1234').and_return(ws)
      allow(ws).to receive(:on).with(:message)
      allow(ws).to receive(:on).with(:open)
      allow(ws).to receive(:on).with(:error)
      allow(ws).to receive(:on).with(:close)
      allow(client).to receive(:fetch_websocket_debug_url).and_return('ws://localhost:9222/devtools/browser/1234')
      allow(client).to receive(:send_message)
    end

    it 'connects to the WebSocket' do
      client.start

      expect(WebSocket::Client::Simple).to have_received(:connect)
    end

    it 'sets up WebSocket event handlers' do
      client.start

      expect(ws).to have_received(:on).with(:message)
      expect(ws).to have_received(:on).with(:open)
      expect(ws).to have_received(:on).with(:error)
      expect(ws).to have_received(:on).with(:close)
    end

    it 'sends a message to discover targets' do
      client.start

      expect(client).to have_received(:send_message).with('Target.setDiscoverTargets', { discover: true })
    end
  end

  describe '#stop' do
    let(:ws) { instance_double(WebSocket::Client::Simple::Client) }

    before do
      allow(WebSocket::Client::Simple).to receive(:connect).with('ws://localhost:9222/devtools/browser/1234').and_return(ws)
      allow(ws).to receive(:on).with(:message)
      allow(ws).to receive(:on).with(:open)
      allow(ws).to receive(:on).with(:error)
      allow(ws).to receive(:on).with(:close)
      allow(ws).to receive(:close)
      allow(client).to receive(:fetch_websocket_debug_url).and_return('ws://localhost:9222/devtools/browser/1234')
      allow(client).to receive(:send_message)
    end

    it 'closes the WebSocket' do
      client.start
      client.stop

      expect(ws).to have_received(:close)
    end
  end

  describe '#send_message' do
    let(:ws) { instance_double(WebSocket::Client::Simple::Client) }
    let(:queue) { instance_double(Queue) }

    before do
      allow(Queue).to receive(:new).and_return(queue)
      allow(queue).to receive(:pop)
      allow(WebSocket::Client::Simple).to receive(:connect).with('ws://localhost:9222/devtools/browser/1234').and_return(ws)
      allow(ws).to receive(:on).with(:message)
      allow(ws).to receive(:on).with(:open)
      allow(ws).to receive(:on).with(:error)
      allow(ws).to receive(:on).with(:close)
      allow(ws).to receive(:send)
      allow(client).to receive(:fetch_websocket_debug_url).and_return('ws://localhost:9222/devtools/browser/1234')
    end

    it 'adds a callback queue' do
      client.start
      client.send_message('Target.setDiscoverTargets', { discover: true })

      expect(queue).to have_received(:pop).twice
    end

    it 'sends a message to the WebSocket' do
      client.start
      client.send_message('Target.setDiscoverTargets', { discover: true })

      expect(ws).to have_received(:send).with('{"id":1,"method":"Target.setDiscoverTargets","params":{"discover":true}}')
    end
  end

  describe '#reconnect' do
    let(:ws) { instance_double(WebSocket::Client::Simple::Client) }

    before do
      allow(WebSocket::Client::Simple).to receive(:connect).with('ws://localhost:9222/devtools/browser/1234').and_return(ws)
      allow(ws).to receive(:on).with(:message)
      allow(ws).to receive(:on).with(:open)
      allow(ws).to receive(:on).with(:error)
      allow(ws).to receive(:on).with(:close)
      allow(ws).to receive(:close)
      allow(client).to receive(:fetch_websocket_debug_url).and_return('ws://localhost:9222/devtools/browser/1234')
      allow(client).to receive(:send_message)
    end

    it 'reconnects to the WebSocket' do
      client.start
      client.reconnect

      expect(WebSocket::Client::Simple).to have_received(:connect).twice
    end
  end

  describe '#handle_message' do
    let(:ws) { instance_double(WebSocket::Client::Simple::Client) }
    let(:queue) { instance_double(Queue) }

    before do
      allow(Queue).to receive(:new).and_return(queue)
      allow(queue).to receive(:pop)
      allow(queue).to receive(:push)
      allow(WebSocket::Client::Simple).to receive(:connect).with('ws://localhost:9222/devtools/browser/1234').and_return(ws)
      allow(ws).to receive(:on).with(:message)
      allow(ws).to receive(:on).with(:open)
      allow(ws).to receive(:on).with(:error)
      allow(ws).to receive(:on).with(:close)
      allow(ws).to receive(:send)
      allow(client).to receive(:fetch_websocket_debug_url).and_return('ws://localhost:9222/devtools/browser/1234')
    end

    it 'handles the message' do
      client.start
      client.handle_message({ 'method' => 'Target.targetCreated' })

      expect(queue).to have_received(:pop)
    end

    context 'when the message is a response' do
      it 'handles the response' do
        client.start
        client.handle_message({ 'id' => 1, 'result' => { 'targetId' => '1' } })

        expect(queue).to have_received(:pop)
      end
    end

    context 'when the message is an event' do
      it 'handles the event' do
        client.start
        client.handle_message({ 'method' => 'Target.targetCreated' })

        expect(queue).to have_received(:pop)
      end
    end
  end

  describe '#on_message' do
    let(:ws) { instance_double(WebSocket::Client::Simple::Client) }
    let(:queue) { instance_double(Queue) }

    before do
      allow(Queue).to receive(:new).and_return(queue)
      allow(queue).to receive(:pop)
      allow(queue).to receive(:push)
      allow(WebSocket::Client::Simple).to receive(:connect).with('ws://localhost:9222/devtools/browser/1234').and_return(ws)
      allow(ws).to receive(:on).with(:message)
      allow(ws).to receive(:on).with(:open)
      allow(ws).to receive(:on).with(:error)
      allow(ws).to receive(:on).with(:close)
      allow(ws).to receive(:send)
      allow(client).to receive(:fetch_websocket_debug_url).and_return('ws://localhost:9222/devtools/browser/1234')
    end

    it 'adds a listener' do
      listener = proc { |message| puts message }
      client.start
      client.on_message(&listener)

      expect(Chromate::Client.listeners).to include(listener)
    end

    it 'calls the listener' do
      listener = proc { |message| puts message }
      client.start
      client.on_message(&listener)
      client.handle_message({ 'method' => 'Target.targetCreated' })

      expect(queue).to have_received(:pop)
    end
  end

  describe '#fetch_websocket_debug_url' do
  end
end
