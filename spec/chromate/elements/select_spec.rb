# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chromate::Elements::Select do
  let(:selector) { '#test-select' }
  let(:client) { instance_double('Chromate::Client') }
  let(:mouse_controller) { instance_double('Chromate::Hardwares::MouseController') }
  let(:keyboard_controller) { instance_double('Chromate::Hardwares::KeyboardController') }
  let(:node_id) { 123 }
  let(:object_id) { 'object-123' }
  let(:root_id) { 456 }

  let(:configuration) do
    instance_double('Chromate::Configuration',
                    mouse_controller: mouse_controller,
                    keyboard_controller: keyboard_controller,
                    native_control: native_control)
  end

  let(:native_control) { false }

  before do
    allow(Chromate).to receive(:configuration).and_return(configuration)
    allow(mouse_controller).to receive(:set_element).and_return(mouse_controller)
    allow(keyboard_controller).to receive(:set_element).and_return(keyboard_controller)
    mock_default_element_responses(client, root_id: root_id, node_id: node_id, object_id: object_id)
  end

  subject(:select) { described_class.new(selector, client) }

  describe '#select_option' do
    let(:option_value) { 'test-option' }
    let(:option_node_id) { 789 }
    let(:option_object_id) { 'option-789' }

    before do
      mock_element_click(client, node_id: node_id)
      allow(mouse_controller).to receive(:click)

      # Mock pour l'option
      allow(client).to receive(:send_message)
        .with('DOM.querySelector', nodeId: root_id, selector: "option[value='#{option_value}']")
        .and_return({ 'nodeId' => option_node_id })
      allow(client).to receive(:send_message)
        .with('DOM.resolveNode', nodeId: option_node_id)
        .and_return({ 'object' => { 'objectId' => option_object_id } })
      mock_element_click(client, node_id: option_node_id)

      # Mock pour l'évaluation du script JavaScript
      allow(client).to receive(:send_message)
        .with('Runtime.callFunctionOn', hash_including(
          objectId: object_id,
          returnByValue: true
        ))
        .and_return({ 'result' => { 'value' => nil } })

      # Mock pour le scrollIntoView
      allow(client).to receive(:send_message)
        .with('DOM.scrollIntoViewIfNeeded', nodeId: option_node_id)
        .and_return({})
    end

    context 'when native_control is false' do
      let(:native_control) { false }

      before do
        mock_select_option(client, object_id: object_id, value: option_value)
      end

      it 'selects the option using JavaScript and clicks it' do
        select.select_option(option_value)
        expect(mouse_controller).to have_received(:click).twice # Once for select, once for option
      end
    end

    context 'when native_control is true' do
      let(:native_control) { true }

      it 'only clicks the select and option elements' do
        select.select_option(option_value)
        expect(mouse_controller).to have_received(:click).twice # Once for select, once for option
      end
    end

    it 'returns self for method chaining' do
      expect(select.select_option(option_value)).to eq(select)
    end
  end

  describe '#selected_value' do
    let(:selected_value) { 'selected-option' }

    before do
      mock_select_selected_value(client, object_id: object_id, value: selected_value)
    end

    it 'returns the currently selected value' do
      expect(select.selected_value).to eq(selected_value)
    end
  end

  describe '#selected_text' do
    let(:selected_text) { 'Selected Option Text' }

    before do
      mock_select_selected_text(client, object_id: object_id, text: selected_text)
    end

    it 'returns the text of the currently selected option' do
      expect(select.selected_text).to eq(selected_text)
    end
  end
end
