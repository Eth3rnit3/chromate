# frozen_string_literal: true

require 'chromate/element'

module Chromate
  module Elements
    class Checkbox < Element
      def initialize(selector, client, **options)
        super
        raise InvalidSelectorError, selector unless checkbox?
      end

      def checkbox?
        tag_name == 'input' && property('type') == 'checkbox'
      end

      def checked?
        property('checked')
      end

      def check
        click unless checked?
        self
      end

      def uncheck
        click if checked?
        self
      end

      def toggle
        click
        self
      end
    end
  end
end
