# frozen_string_literal: true

module Chromate
  class Element
    class NotFoundError < StandardError; end
    class InvalidSelectorError < StandardError; end
    attr_reader :selector, :client

    # @param [String] selector
    # @param [Chromate::Client] client
    def initialize(selector, client)
      @selector = selector
      @client   = client
      @id       = find
    end

    # @return [String]
    def html
      return @html if @html

      @html = client.send_message('DOM.getOuterHTML', objectId: @id)
      @html = @html['outerHTML']
    end

    private

    # @return [String]
    def find
      document  = client.send_message('DOM.getDocument')
      root_id   = document['root']['nodeId']
      result    = client.send_message('DOM.querySelector', nodeId: root_id, selector: selector)
      raise NotFoundError, "Element not found with selector: #{selector}" unless result['nodeId']

      node_info = client.send_message('DOM.resolveNode', nodeId: result['nodeId'])
      raise InvalideSelectorError, "Unable to resolve element with selector: #{selector}" unless node_info['object']

      node_info['object']['objectId']
    end
  end
end