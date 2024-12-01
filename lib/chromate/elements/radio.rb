# frozen_string_literal: true

require 'chromate/element'

module Chromate
  module Elements
    class Radio < Element
      def initialize(selector, client, **options)
        super
        raise InvalidSelectorError, selector unless radio?
      end

      # @return [Boolean]
      def radio?
        tag_name == 'input' && attributes['type'] == 'radio'
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
    end
  end
end
