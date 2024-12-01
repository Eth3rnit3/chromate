# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chromate::Element do
  let(:selector) { '#test-element' }
  let(:client) { instance_double(Chromate::Client) }
  let(:mouse_controller) { instance_double(Chromate::Hardwares::MouseController) }
  let(:keyboard_controller) { instance_double(Chromate::Hardwares::KeyboardController) }
  let(:node_id) { 123 }
  let(:object_id) { 'object-123' }
  let(:root_id) { 456 }

  let(:configuration) do
    instance_double(Chromate::Configuration,
                    mouse_controller: mouse_controller,
                    keyboard_controller: keyboard_controller)
  end

  before do
    allow(Chromate).to receive(:configuration).and_return(configuration)
    allow(mouse_controller).to receive(:set_element).and_return(mouse_controller)
    allow(keyboard_controller).to receive(:set_element).and_return(keyboard_controller)

    mock_default_element_responses(client, root_id: root_id, node_id: node_id, object_id: object_id)
  end

  subject(:element) { described_class.new(selector, client) }

  describe '#initialize' do
    it 'sets the selector and client' do
      expect(element.selector).to eq(selector)
      expect(element.client).to eq(client)
    end

    context 'when element is not found' do
      before do
        mock_element_not_found(client, root_id: root_id, selector: selector)
      end

      it 'raises NotFoundError' do
        expect { described_class.new(selector, client) }.to raise_error(Chromate::Element::NotFoundError)
      end
    end
  end

  describe '#text' do
    before do
      mock_element_text(client, object_id: object_id, text: 'Test Text')
    end

    it 'returns the element text content' do
      expect(element.text).to eq('Test Text')
    end
  end

  describe '#value' do
    before do
      mock_element_value(client, object_id: object_id, value: 'Test Value')
    end

    it 'returns the element value' do
      expect(element.value).to eq('Test Value')
    end
  end

  describe '#attributes' do
    before do
      allow(client).to receive(:send_message)
        .with('DOM.getAttributes', nodeId: node_id)
        .and_return({ 'attributes' => %w[class test-class data-test value] })
    end

    it 'returns element attributes as a hash' do
      expect(element.attributes).to eq({ 'class' => 'test-class', 'data-test' => 'value' })
    end
  end

  describe '#tag_name' do
    before do
      allow(client).to receive(:send_message)
        .with('Runtime.callFunctionOn',
              hash_including(functionDeclaration: 'function() { return this.tagName.toLowerCase(); }',
                             objectId: object_id,
                             returnByValue: true))
        .and_return({ 'result' => { 'value' => 'div' } })
    end

    it 'returns the lowercase tag name' do
      expect(element.tag_name).to eq('div')
    end
  end

  describe '#click' do
    before do
      allow(mouse_controller).to receive(:click)
    end

    it 'triggers a mouse click' do
      expect(mouse_controller).to receive(:click)
      element.click
    end

    it 'returns self' do
      expect(element.click).to eq(element)
    end
  end

  describe '#type' do
    before do
      mock_element_focus(client, node_id: node_id)
      allow(keyboard_controller).to receive(:type)
    end

    it 'focuses the element and types the text' do
      expect(client).to receive(:send_message).with('DOM.focus', nodeId: node_id)
      expect(keyboard_controller).to receive(:type).with('test text')
      element.type('test text')
    end

    it 'returns self' do
      expect(element.type('test')).to eq(element)
    end
  end

  describe '#find_element' do
    let(:child_node_id) { 789 }
    let(:child_object_id) { 'object-789' }

    before do
      allow(client).to receive(:send_message)
        .with('DOM.querySelectorAll', nodeId: node_id, selector: '.child')
        .and_return({ 'nodeIds' => [child_node_id] })
      allow(client).to receive(:send_message)
        .with('DOM.resolveNode', nodeId: child_node_id)
        .and_return({ 'object' => { 'objectId' => child_object_id } })
    end

    it 'returns the first matching child element' do
      child = element.find_element('.child')
      expect(child).to be_a(described_class)
      expect(child.selector).to eq('.child')
    end
  end

  describe '#shadow_root?' do
    context 'when element has shadow root' do
      before do
        allow(client).to receive(:send_message)
          .with('DOM.describeNode', nodeId: node_id)
          .and_return({ 'node' => { 'shadowRoots' => [{ 'nodeId' => 999 }] } })
      end

      it 'returns true' do
        expect(element.shadow_root?).to be true
      end
    end

    context 'when element has no shadow root' do
      before do
        allow(client).to receive(:send_message)
          .with('DOM.describeNode', nodeId: node_id)
          .and_return({ 'node' => { 'shadowRoots' => [] } })
      end

      it 'returns false' do
        expect(element.shadow_root?).to be false
      end
    end
  end

  describe '#bounding_box' do
    let(:box_model) do
      {
        'model' => {
          'content' => [10, 20],
          'width' => 100,
          'height' => 50
        }
      }
    end

    before do
      allow(client).to receive(:send_message)
        .with('DOM.getBoxModel', objectId: object_id)
        .and_return(box_model)
    end

    it 'returns the element dimensions' do
      expect(element.x).to eq(10)
      expect(element.y).to eq(20)
      expect(element.width).to eq(100)
      expect(element.height).to eq(50)
    end
  end

  describe '#set_attribute' do
    before do
      allow(client).to receive(:send_message).with('DOM.setAttributeValue', any_args)
      allow(client).to receive(:send_message).with('DOM.dispatchEvent', any_args)
    end

    it 'sets the attribute and dispatches change event' do
      expect(client).to receive(:send_message)
        .with('DOM.setAttributeValue', nodeId: node_id, name: 'data-test', value: 'new-value')
      expect(client).to receive(:send_message)
        .with('DOM.dispatchEvent', nodeId: node_id, type: 'change')

      element.set_attribute('data-test', 'new-value')
    end
  end

  describe '#press_enter' do
    before do
      allow(keyboard_controller).to receive(:press_key)
      allow(client).to receive(:send_message)
        .with('Runtime.callFunctionOn', hash_including(functionDeclaration: /function\(\) {.*}/m))
        .and_return({ 'result' => { 'value' => nil } })
    end

    it 'simulates pressing enter and submits parent form' do
      element.press_enter
      expect(keyboard_controller).to have_received(:press_key).with('Enter')
    end
  end
end
