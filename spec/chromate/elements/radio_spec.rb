# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chromate::Elements::Radio do
  let(:selector) { '#test-radio' }
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
    context 'with valid radio element' do
      before do
        mock_element_tag_name(client, object_id: object_id, tag_name: 'input')
        mock_element_attributes(client, node_id: node_id, attributes: { 'type' => 'radio' })
      end

      it 'creates a new radio instance' do
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

  describe '#radio?' do
    subject(:radio) { described_class.new(selector, client) }

    before do
      mock_element_tag_name(client, object_id: object_id, tag_name: 'input')
      mock_element_attributes(client, node_id: node_id, attributes: { 'type' => 'radio' })
    end

    it 'returns true for radio elements' do
      expect(radio.radio?).to be true
    end
  end

  describe '#checked?' do
    subject(:radio) { described_class.new(selector, client) }

    before do
      mock_element_tag_name(client, object_id: object_id, tag_name: 'input')
      mock_element_attributes(client, node_id: node_id, attributes: { 'type' => 'radio', 'checked' => checked })
    end

    context 'when radio is checked' do
      let(:checked) { 'true' }

      it 'returns true' do
        expect(radio.checked?).to be true
      end
    end

    context 'when radio is unchecked' do
      let(:checked) { nil }

      it 'returns false' do
        expect(radio.checked?).to be false
      end
    end
  end

  describe '#check' do
    subject(:radio) { described_class.new(selector, client) }

    before do
      mock_element_tag_name(client, object_id: object_id, tag_name: 'input')
      mock_element_attributes(client, node_id: node_id, attributes: { 'type' => 'radio', 'checked' => checked })
      mock_element_click(client, node_id: node_id)
    end

    before do
      allow(mouse_controller).to receive(:click)
    end

    context 'when radio is already checked' do
      let(:checked) { 'true' }

      it 'does not click the radio' do
        radio.check
        expect(mouse_controller).not_to have_received(:click)
      end
    end

    context 'when radio is unchecked' do
      let(:checked) { nil }

      it 'clicks the radio' do
        radio.check
        expect(mouse_controller).to have_received(:click)
      end
    end

    context 'when checking for method chaining' do
      let(:checked) { nil }

      it 'returns self for method chaining' do
        expect(radio.check).to eq(radio)
      end
    end
  end

  describe '#uncheck' do
    subject(:radio) { described_class.new(selector, client) }

    before do
      mock_element_tag_name(client, object_id: object_id, tag_name: 'input')
      mock_element_attributes(client, node_id: node_id, attributes: { 'type' => 'radio', 'checked' => checked })
      mock_element_click(client, node_id: node_id)
    end

    before do
      allow(mouse_controller).to receive(:click)
    end

    context 'when radio is checked' do
      let(:checked) { 'true' }

      it 'clicks the radio' do
        radio.uncheck
        expect(mouse_controller).to have_received(:click)
      end
    end

    context 'when radio is already unchecked' do
      let(:checked) { nil }

      it 'does not click the radio' do
        radio.uncheck
        expect(mouse_controller).not_to have_received(:click)
      end
    end

    context 'when unchecking for method chaining' do
      let(:checked) { 'true' }

      it 'returns self for method chaining' do
        expect(radio.uncheck).to eq(radio)
      end
    end
  end
end
