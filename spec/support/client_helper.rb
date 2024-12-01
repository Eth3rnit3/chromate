# frozen_string_literal: true

module Support
  module ClientHelper
    def mock_default_element_responses(client, root_id: 456, node_id: 123, object_id: 'object-123')
      # Mock pour le document
      allow(client).to receive(:send_message)
        .with('DOM.getDocument')
        .and_return({ 'root' => { 'nodeId' => root_id } })

      # Mock pour la recherche d'élément
      allow(client).to receive(:send_message)
        .with('DOM.querySelector', any_args)
        .and_return({ 'nodeId' => node_id })
      allow(client).to receive(:send_message)
        .with('DOM.resolveNode', any_args)
        .and_return({ 'object' => { 'objectId' => object_id } })

      # Mock pour le shadow DOM
      allow(client).to receive(:send_message)
        .with('DOM.describeNode', any_args)
        .and_return({ 'node' => { 'shadowRoots' => [] } })
      allow(client).to receive(:send_message)
        .with('DOM.querySelectorAll', any_args)
        .and_return({ 'nodeIds' => [] })
    end

    def mock_element_not_found(client, root_id:, selector:)
      allow(client).to receive(:send_message).with(any_args).and_return({})
      allow(client).to receive(:send_message)
        .with('DOM.getDocument')
        .and_return({ 'root' => { 'nodeId' => root_id } })
      allow(client).to receive(:send_message)
        .with('DOM.querySelector', nodeId: root_id, selector: selector)
        .and_return({ 'nodeId' => nil })
    end

    def mock_element_text(client, object_id:, text:)
      allow(client).to receive(:send_message)
        .with('Runtime.callFunctionOn',
              hash_including(functionDeclaration: 'function() { return this.innerText; }',
                           objectId: object_id,
                           returnByValue: true))
        .and_return({ 'result' => { 'value' => text } })
    end

    def mock_element_value(client, object_id:, value:)
      allow(client).to receive(:send_message)
        .with('Runtime.callFunctionOn',
              hash_including(functionDeclaration: 'function() { return this.value; }',
                           objectId: object_id,
                           returnByValue: true))
        .and_return({ 'result' => { 'value' => value } })
    end

    def mock_element_focus(client, node_id:)
      allow(client).to receive(:send_message).with('DOM.focus', nodeId: node_id)
    end

    def mock_element_property(client, object_id:, property:, value:)
      allow(client).to receive(:send_message)
        .with('Runtime.callFunctionOn',
              hash_including(functionDeclaration: "function() { return this['#{property}']; }",
                           objectId: object_id,
                           returnByValue: true))
        .and_return({ 'result' => { 'value' => value } })
    end

    def mock_element_tag_name(client, object_id:, tag_name:)
      allow(client).to receive(:send_message)
        .with('Runtime.callFunctionOn',
              hash_including(functionDeclaration: 'function() { return this.tagName.toLowerCase(); }',
                           objectId: object_id,
                           returnByValue: true))
        .and_return({ 'result' => { 'value' => tag_name } })
    end

    def mock_element_click(client, node_id:)
      allow(client).to receive(:send_message)
        .with('DOM.focus', nodeId: node_id)
      allow(client).to receive(:send_message)
        .with('DOM.scrollIntoViewIfNeeded', nodeId: node_id)
    end

    def mock_element_evaluate_script(client, object_id:, script:, result:)
      allow(client).to receive(:send_message)
        .with('Runtime.callFunctionOn',
              hash_including(functionDeclaration: script,
                           objectId: object_id,
                           returnByValue: true))
        .and_return({ 'result' => { 'value' => result } })
    end

    def mock_option_bounding_box(client, object_id:, x:, y:, width:, height:)
      script = <<~JAVASCRIPT
          function() {
            const select = this.closest('select');
            const rect = select.getBoundingClientRect();
            return {
              x: rect.x,
              y: rect.y,
              width: rect.width,
              height: rect.height
            };
          }
      JAVASCRIPT

      mock_element_evaluate_script(client, object_id: object_id, script: script,
                                 result: { 'x' => x, 'y' => y, 'width' => width, 'height' => height })
    end

    def mock_select_option(client, object_id:, value:)
      script = <<~JAVASCRIPT
          function() {
            this.focus();
            this.dispatchEvent(new MouseEvent('mousedown'));

            const options = Array.from(this.options);
            const option = options.find(opt =>
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

      allow(client).to receive(:send_message)
        .with('Runtime.callFunctionOn',
              hash_including(functionDeclaration: script,
                           objectId: object_id,
                           arguments: [{ value: value }],
                           returnByValue: true))
    end

    def mock_select_selected_value(client, object_id:, value:)
      allow(client).to receive(:send_message)
        .with('Runtime.callFunctionOn',
              hash_including(functionDeclaration: 'function() { return this.value; }',
                           objectId: object_id,
                           returnByValue: true))
        .and_return({ 'result' => { 'value' => value } })
    end

    def mock_select_selected_text(client, object_id:, text:)
      script = 'function() {
            const option = this.options[this.selectedIndex];
            return option ? option.textContent.trim() : null;
          }'

      allow(client).to receive(:send_message)
        .with('Runtime.callFunctionOn',
              hash_including(functionDeclaration: script,
                           objectId: object_id,
                           returnByValue: true))
        .and_return({ 'result' => { 'value' => text } })
    end

    def mock_element_attributes(client, node_id:, attributes:)
      allow(client).to receive(:send_message)
        .with('DOM.getAttributes', nodeId: node_id)
        .and_return({ 'attributes' => attributes.to_a.flatten })
    end
  end
end