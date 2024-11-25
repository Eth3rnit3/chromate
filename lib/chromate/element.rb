# frozen_string_literal: true

module Chromate
  class Element
    class NotFoundError < StandardError
      def initialize(selector, root_id)
        super("Element not found with selector: #{selector} under root_id: #{root_id}")
      end
    end

    class InvalidSelectorError < StandardError
      def initialize(selector)
        super("Unable to resolve element with selector: #{selector}")
      end
    end
    attr_reader :selector, :client

    # @param [String] selector
    # @param [Chromate::Client] client
    # @option [Integer] node_id
    # @option [String] object_id
    # @option [Integer] root_id
    def initialize(selector, client, node_id: nil, object_id: nil, root_id: nil)
      @selector   = selector
      @client     = client
      @object_id  = object_id
      @node_id    = node_id
      @object_id, @node_id = magick_find(selector, root_id) unless @object_id && @node_id
      @root_id = root_id || document['root']['nodeId']
    end

    # @return [Chromate::Hardwares::MouseController]
    def mouse
      Chromate.configuration.mouse_controller.set_element(self)
    end

    # @return [Chromate::Hardwares::KeyboardController]
    def keyboard
      Chromate.configuration.keyboard_controller.set_element(self)
    end

    # @return [String]
    def inspect
      value = selector.length > 20 ? "#{selector[0..20]}..." : selector
      "#<Chromate::Element:#{value}>"
    end

    # @return [String]
    def text
      result = client.send_message('Runtime.callFunctionOn', functionDeclaration: 'function() { return this.innerText; }', objectId: @object_id)
      result['result']['value']
    end

    # @return [String]
    def html
      html = client.send_message('DOM.getOuterHTML', objectId: @object_id)
      html['outerHTML']
    end

    # @return [Hash]
    def attributes
      result = client.send_message('DOM.getAttributes', nodeId: @node_id)
      Hash[*result['attributes']]
    end

    # @param [String] name
    # @param [String] value
    # @return [self]
    def set_attribute(name, value)
      client.send_message('DOM.setAttributeValue', nodeId: @node_id, name: name, value: value)
      dispatch_event('change')
    end

    # @return [Hash]
    def bounding_box
      return @bounding_box if @bounding_box

      result = client.send_message('DOM.getBoxModel', objectId: @object_id)
      @bounding_box = result['model']
    end

    # @return [Integer]
    def x
      bounding_box['content'][0]
    end

    # @return [Integer]
    def y
      bounding_box['content'][1]
    end

    # @return [Integer]
    def width
      bounding_box['width']
    end

    # @return [Integer]
    def height
      bounding_box['height']
    end

    # @return [self]
    def focus
      client.send_message('DOM.focus', nodeId: @node_id)

      self
    end

    # @return [self]
    def click
      mouse.click

      self
    end

    # @return [self]
    def hover
      mouse.hover

      self
    end

    # @param [String] text
    # @return [self]
    def type(text)
      focus
      keyboard.type(text)

      self
    end

    # @return [self]
    def press_enter
      keyboard.press_key('Enter')
      submit_parent_form

      self
    end

    def drop_to(element)
      mouse.drag_and_drop_to(element)

      self
    end

    # @param [String] selector
    # @return [Chromate::Element]
    def find_element(selector)
      find_elements(selector, max: 1).first
    end

    # @param [String] selector
    # @option [Integer] max
    # @return [Array<Chromate::Element>]
    def find_elements(selector, max: 0)
      results = client.send_message('DOM.querySelectorAll', nodeId: @node_id, selector: selector)
      results['nodeIds'].each_with_index.filter_map do |node_id, idx|
        node_info = client.send_message('DOM.resolveNode', nodeId: node_id)
        next unless node_info['object']
        break if max.positive? && idx >= max

        Element.new(selector, client, node_id: node_id, object_id: node_info['object']['objectId'], root_id: @node_id)
      end
    end

    # @return [Integer]
    def shadow_root_id
      return @shadow_root_id if @shadow_root_id

      node_info = client.send_message('DOM.describeNode', nodeId: @node_id)
      @shadow_root_id = node_info.dig('node', 'shadowRoots', 0, 'nodeId')
    end

    # @return [Boolean]
    def shadow_root?
      !!shadow_root_id
    end

    # @param [String] selector
    # @return [Chromate::Element|NilClass]
    def find_shadow_child(selector)
      find_shadow_children(selector).first
    end

    # @param [String] selector
    # @return [Array<Chromate::Element>]
    def find_shadow_children(selector)
      return [] unless shadow_root?

      results = client.send_message('DOM.querySelectorAll', nodeId: shadow_root_id, selector: selector)
      (results&.dig('nodeIds') || []).map do |node_id|
        node_info = client.send_message('DOM.resolveNode', nodeId: node_id)
        next unless node_info['object']

        Element.new(selector, client, node_id: node_id, object_id: node_info['object']['objectId'], root_id: shadow_root_id)
      end
    end

    private

    # @param [String] event
    # @return [void]
    def dispatch_event(event)
      client.send_message('DOM.dispatchEvent', nodeId: @node_id, type: event)
    end

    # @return [Array] [object_id, node_id]
    def find(selector, root_id = nil)
      @root_id  = root_id || document['root']['nodeId']
      result    = client.send_message('DOM.querySelector', nodeId: @root_id, selector: selector)
      raise NotFoundError.new(selector, @root_id) unless result['nodeId']

      node_info = client.send_message('DOM.resolveNode', nodeId: result['nodeId'])
      raise InvalidSelectorError, selector unless node_info['object']

      [node_info['object']['objectId'], result['nodeId']]
    end

    # @param [String] selector
    # @option [Integer] root_id
    # @return [Chromate::Element, nil]
    def magick_find(selector, root_id = nil)
      find(selector, root_id)
    rescue NotFoundError, InvalidSelectorError
      el = find_in_shadow_recursively(selector)
      raise NotFoundError.new(selector, @root_id) unless el

      el
    end

    # @param [String] selector
    # @return [Chromate::Element, nil]
    def find_in_shadow_recursively(selector)
      shadow_children = find_shadow_children('*')
      shadow_children.each do |child|
        found_element = child.find_element(selector) || child.find_in_shadow_recursively(selector)
        return found_element if found_element
      end

      nil
    end

    def document
      @document ||= client.send_message('DOM.getDocument')
    end

    def submit_parent_form
      script = <<~JAVASCRIPT
        function() {
          const form = this.closest('form');
          if (form) {
            const submitEvent = new Event('submit', {
              bubbles: true,
              cancelable: true
            });
            if (form.dispatchEvent(submitEvent)) {
              form.submit();
            }
          }
        }
      JAVASCRIPT

      client.send_message('Runtime.callFunctionOn',
                          functionDeclaration: script,
                          objectId: @object_id)
    end
  end
end
