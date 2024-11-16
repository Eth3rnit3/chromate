# frozen_string_literal: true

module Chromate
  module Actions
    module Navigate
      # @param [String] url
      # @return [self]
      def navigate_to(url)
        @client.send_message('Page.enable')
        @client.send_message('Page.navigate', url: url)
        wait_for_page_load
      end

      # @return [self]
      def wait_for_page_load # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
        page_loaded = false
        dom_content_loaded = false
        frame_stopped_loading = false

        # Use Mutex for synchronization
        mutex = Mutex.new
        condition = ConditionVariable.new

        # Subscribe to websocket messages
        listener = proc do |message|
          mutex.synchronize do
            case message['method']
            when 'Page.domContentEventFired'
              dom_content_loaded = true
              condition.signal if dom_content_loaded && page_loaded && frame_stopped_loading
            when 'Page.loadEventFired'
              page_loaded = true
              condition.signal if dom_content_loaded && page_loaded && frame_stopped_loading
            when 'Page.frameStoppedLoading'
              frame_stopped_loading = true
              condition.signal if dom_content_loaded && page_loaded && frame_stopped_loading
            end
          end
        end

        @client.on_message(&listener)

        # Wait for all three events (DOMContent, Load and FrameStoppedLoading) with a timeout
        Timeout.timeout(15) do
          mutex.synchronize do
            condition.wait(mutex) until dom_content_loaded && page_loaded && frame_stopped_loading
          end
        end

        @client.on_message { |msg| } # Remove listener

        self
      end

      # @return [self]
      def refresh
        @client.send_message('Page.reload')
        wait_for_page_load
        self
      end

      # @return [self]
      def go_back
        @client.send_message('Page.goBack')
        wait_for_page_load
        self
      end
    end
  end
end
