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

        # Utiliser un Mutex pour la synchronisation
        mutex = Mutex.new
        condition = ConditionVariable.new

        # S'abonner aux messages WebSocket
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

        # Attendre les trois événements (DOMContent, Load et FrameStoppedLoading) avec un timeout
        Timeout.timeout(15) do
          mutex.synchronize do
            condition.wait(mutex) until dom_content_loaded && page_loaded && frame_stopped_loading
          end
        end

        # Nettoyer l'écouteur WebSocket
        @client.on_message { |msg| } # Supprime tous les anciens écouteurs en ajoutant un listener vide

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
