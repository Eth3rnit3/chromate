# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chromate::Elements::Checkbox do
  let(:selector) { '#test-checkbox' }
  let(:client) { instance_double('Chromate::Client') }
  let(:mouse_controller) { instance_double('Chromate::Hardwares::MouseController') }
  let(:keyboard_controller) { instance_double('Chromate::Hardwares::KeyboardController') }
  let(:node_id) { 123 }
  let(:object_id) { 'object-123' }
  let(:root_id) { 456 }

  let(:configuration) do
    instance_double('Chromate::Configuration',
                    mouse_controller: mouse_controller,
                    keyboard_controller: keyboard_controller)
  end

  before do
    allow(Chromate).to receive(:configuration).and_return(configuration)
    allow(mouse_controller).to receive(:set_element).and_return(mouse_controller)
    allow(keyboard_controller).to receive(:set_element).and_return(keyboard_controller)
    mock_default_element_responses(client, root_id: root_id, node_id: node_id, object_id: object_id)
  end

  describe '#initialize' do
    context 'with valid checkbox element' do
      before do
        mock_element_tag_name(client, object_id: object_id, tag_name: 'input')
        mock_element_attributes(client, node_id: node_id, attributes: { 'type' => 'checkbox' })
      end

      it 'creates a new checkbox instance' do
        expect { described_class.new(selector, client) }.not_to raise_error
      end
    end

    context 'with invalid element' do
      before do
        mock_element_tag_name(client, object_id: object_id, tag_name: 'div')
      end

      it 'raises InvalidSelectorError' do
        expect { described_class.new(selector, client) }
          .to raise_error(Chromate::Element::InvalidSelectorError)
      end
    end
  end

  describe '#checkbox?' do
    subject(:checkbox) { described_class.new(selector, client) }

    before do
      mock_element_tag_name(client, object_id: object_id, tag_name: 'input')
      mock_element_attributes(client, node_id: node_id, attributes: { 'type' => 'checkbox' })
    end

    it 'returns true for checkbox elements' do
      expect(checkbox.checkbox?).to be true
    end
  end

  describe '#checked?' do
    subject(:checkbox) { described_class.new(selector, client) }

    before do
      mock_element_tag_name(client, object_id: object_id, tag_name: 'input')
      mock_element_attributes(client, node_id: node_id, attributes: { 'type' => 'checkbox', 'checked' => checked })
    end

    context 'when checkbox is checked' do
      let(:checked) { 'true' }

      it 'returns true' do
        expect(checkbox.checked?).to be true
      end
    end

    context 'when checkbox is unchecked' do
      let(:checked) { nil }

      it 'returns false' do
        expect(checkbox.checked?).to be false
      end
    end
  end

  describe '#check' do
    subject(:checkbox) { described_class.new(selector, client) }

    before do
      mock_element_tag_name(client, object_id: object_id, tag_name: 'input')
      mock_element_attributes(client, node_id: node_id, attributes: { 'type' => 'checkbox', 'checked' => checked })
      mock_element_click(client, node_id: node_id)
      allow(mouse_controller).to receive(:click)
    end

    context 'when checkbox is already checked' do
      let(:checked) { 'true' }

      it 'does not click the checkbox' do
        checkbox.check
        expect(mouse_controller).not_to have_received(:click)
      end
    end

    context 'when checkbox is unchecked' do
      let(:checked) { nil }

      it 'clicks the checkbox' do
        checkbox.check
        expect(mouse_controller).to have_received(:click)
      end
    end

    context 'when checking for method chaining' do
      let(:checked) { nil }

      it 'returns self for method chaining' do
        expect(checkbox.check).to eq(checkbox)
      end
    end
  end

  describe '#uncheck' do
    subject(:checkbox) { described_class.new(selector, client) }

    before do
      mock_element_tag_name(client, object_id: object_id, tag_name: 'input')
      mock_element_attributes(client, node_id: node_id, attributes: { 'type' => 'checkbox', 'checked' => checked })
      mock_element_click(client, node_id: node_id)
      allow(mouse_controller).to receive(:click)
    end

    context 'when checkbox is checked' do
      let(:checked) { 'true' }

      it 'clicks the checkbox' do
        checkbox.uncheck
        expect(mouse_controller).to have_received(:click)
      end
    end

    context 'when checkbox is already unchecked' do
      let(:checked) { nil }

      it 'does not click the checkbox' do
        checkbox.uncheck
        expect(mouse_controller).not_to have_received(:click)
      end
    end

    context 'when unchecking for method chaining' do
      let(:checked) { 'true' }

      it 'returns self for method chaining' do
        expect(checkbox.uncheck).to eq(checkbox)
      end
    end
  end

  describe '#toggle' do
    subject(:checkbox) { described_class.new(selector, client) }

    before do
      mock_element_tag_name(client, object_id: object_id, tag_name: 'input')
      mock_element_attributes(client, node_id: node_id, attributes: { 'type' => 'checkbox' })
      mock_element_click(client, node_id: node_id)
      allow(mouse_controller).to receive(:click)
    end

    it 'clicks the checkbox' do
      checkbox.toggle
      expect(mouse_controller).to have_received(:click)
    end

    it 'returns self for method chaining' do
      expect(checkbox.toggle).to eq(checkbox)
    end
  end
end
