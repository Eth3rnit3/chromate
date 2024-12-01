# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chromate::Elements::Option do
  let(:value) { 'test-value' }
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

  describe '#initialize' do
    subject(:option) { described_class.new(value, client) }

    it 'sets the value' do
      expect(option.value).to eq(value)
    end

    it 'constructs the correct selector' do
      expect(option.selector).to eq("option[value='#{value}']")
    end
  end

  describe '#bounding_box' do
    subject(:option) { described_class.new(value, client) }

    let(:x) { 100 }
    let(:y) { 200 }
    let(:width) { 300 }
    let(:height) { 400 }

    before do
      mock_option_bounding_box(client, object_id: object_id, x: x, y: y, width: width, height: height)
    end

    it 'returns the bounding box with adjusted coordinates' do
      expect(option.bounding_box).to eq(
        'content' => [x + 100, y + 100],
        'width' => width,
        'height' => height
      )
    end
  end
end
