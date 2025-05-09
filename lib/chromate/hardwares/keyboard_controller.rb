# frozen_string_literal: true

module Chromate
  module Hardwares
    class KeyboardController
      attr_accessor :element, :client

      # @param [Chromate::Element] element
      # @param [Chromate::Client] client
      def initialize(element: nil, client: nil)
        @element        = element
        @client         = client
        @type_interval  = rand(0.05..0.1)
      end

      # @param [Chromate::Element] element
      # @return [self]
      def set_element(element) # rubocop:disable Naming/AccessorMethodName
        @element = element
        @type_interval = rand(0.05..0.1)

        self
      end

      # @param [String] key
      # @return [self]
      def press_key(_key)
        raise NotImplementedError
      end

      # @param [String] text
      # @return [self]
      def type(text)
        text.each_char do |char|
          sleep(rand(0.01..0.05)) if rand(10).zero?

          press_key(char)
          sleep(@type_interval)
        end

        self
      end
    end
  end
end
