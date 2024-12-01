# frozen_string_literal: true

require 'chromate/element'

module Chromate
  module Elements
    class Checkbox < Element
      def initialize(selector, client, **options)
        super
        raise InvalidSelectorError, selector unless checkbox?
      end

      # @return [Boolean]
      def checked?
        attributes['checked'] == 'true'
      end

      # @return [self]
      def check
        click unless checked?

        self
      end

      # @return [self]
      def uncheck
        click if checked?

        self
      end

      # @return [self]
      def toggle
        click

        self
      end
    end
  end
end
