# frozen_string_literal: true

module Chromate
  module Actions
    module Dom
      # @param selector [String] CSS selector
      # @return [Chromate::Element]
      def find_element(selector)
        Chromate::Element.new(selector, @client)
      end

      # @param selector [String] CSS selector
      # @return [Chromate::Element]
      def click_element(selector)
        find_element(selector).click
      end

      # @param selector [String] CSS selector
      # @return [Chromate::Element]
      def hover_element(selector)
        find_element(selector).hover
      end

      # @param selector [String] CSS selector
      # @param text [String] Text to type
      # @return [Chromate::Element]
      def type_text(selector, text)
        find_element(selector).type(text)
      end

      # @param selector [String] CSS selector
      # @return [String]
      def select_option(selector, option)
        Chromate::Elements::Select.new(selector, @client).select_option(option)
      end

      # @param selector [String] CSS selector
      # @return [String]
      def evaluate_script(script)
        @client.send_message('Runtime.evaluate', expression: script)
      end
    end
  end
end
