# frozen_string_literal: true

require 'chromate/element'

module Chromate
  module Elements
    class Radio < Element
      def initialize(selector = nil, client = nil, **options)
        if selector
          super
          raise InvalidSelectorError, selector unless radio?
        else
          super(**options)
        end
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
