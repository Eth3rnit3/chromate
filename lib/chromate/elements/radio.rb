# frozen_string_literal: true

require 'chromate/element'

module Chromate
  module Elements
    class Radio < Element
      def initialize(selector, client, **options)
        super
        raise InvalidSelectorError, selector unless radio?
      end

      def radio?
        tag_name == 'input' && attributes['type'] == 'radio'
      end

      def checked?
        attributes['checked'] == 'true'
      end

      def check
        click unless checked?
        self
      end

      def uncheck
        click if checked?
        self
      end
    end
  end
end
