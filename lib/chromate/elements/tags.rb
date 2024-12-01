# frozen_string_literal: true

require 'chromate/element'

module Chromate
  module Elements
    module Tags
      def select?
        tag_name == 'select'
      end

      def option?
        tag_name == 'option'
      end

      def radio?
        tag_name == 'input' && property('type') == 'radio'
      end

      def checkbox?
        tag_name == 'input' && property('type') == 'checkbox'
      end

      def base?
        !select? && !option? && !radio? && !checkbox?
      end
    end
  end
end
