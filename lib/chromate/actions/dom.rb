# frozen_string_literal: true

module Chromate
  module Actions
    module Dom
      # @return [String]
      def source
        evaluate_script('document.documentElement.outerHTML')
      end

      # @param selector [String] CSS selector
      # @return [Chromate::Element]
      def find_element(selector)
        base_element = Chromate::Element.new(selector, @client)

        if base_element.select?
          Chromate::Elements::Select.new(selector, @client)
        elsif base_element.option?
          Chromate::Elements::Option.new(base_element.value, @client)
        elsif base_element.radio?
          Chromate::Elements::Radio.new(base_element.value, @client)
        elsif base_element.checkbox?
          Chromate::Elements::Checkbox.new(base_element.value, @client)
        else
          base_element
        end
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
        result = @client.send_message('Runtime.evaluate', expression: script, returnByValue: true)

        result['result']['value']
      rescue StandardError => e
        Chromate::CLogger.log("Error evaluating script: #{e.message}", :error)
        nil
      end
    end
  end
end
