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
  end
end