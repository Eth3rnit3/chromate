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
        tag_name == 'input' && property('type') == 'radio'
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
    end
  end
end
