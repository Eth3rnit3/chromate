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

      def base?
        !select? && !option?
      end
    end
  end
end
