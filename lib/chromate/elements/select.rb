# frozen_string_literal: true

require 'chromate/element'

module Chromate
  module Elements
    class Select < Element
      # @param [String] value
      # @return [self]
      def select_option(value)
        script = javascript

        client.send_message('Runtime.callFunctionOn',
                            functionDeclaration: script,
                            objectId: @object_id,
                            arguments: [{ value: value }])

        self
      rescue StandardError => e
        raise ArgumentError, "Option '#{value}' not found in select" if e.message.include?('Option')

        raise e
      end

      # @return [String|nil]
      def selected_value
        result = client.send_message('Runtime.callFunctionOn',
                                     functionDeclaration: 'function() { return this.value; }',
                                     objectId: @object_id)
        result.dig('result', 'value')
      end

      # @return [String|nil]
      def selected_text
        result = client.send_message('Runtime.callFunctionOn',
                                     functionDeclaration: 'function() {
            const option = this.options[this.selectedIndex];
            return option ? option.textContent.trim() : null;
          }',
                                     objectId: @object_id)
        result.dig('result', 'value')
      end

      # @return [String]
      def javascript
        <<~JAVASCRIPT
          function() {
            this.focus();
            this.dispatchEvent(new MouseEvent('mousedown'));

            const options = Array.from(this.options);
            const option = options.find(opt =>#{" "}
              opt.value === arguments[0] || opt.textContent.trim() === arguments[0]
            );

            if (!option) {
              throw new Error(`Option '${arguments[0]}' not found in select`);
            }

            this.value = option.value;

            this.dispatchEvent(new Event('change', { bubbles: true }));
            this.dispatchEvent(new Event('input', { bubbles: true }));

            this.blur();
          }
        JAVASCRIPT
      end
    end
  end
end
