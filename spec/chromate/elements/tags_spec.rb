# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chromate::Elements::Tags do
  let(:test_class) do
    Class.new do
      include Chromate::Elements::Tags

      attr_reader :client

      def initialize(client)
        @client = client
      end

      attr_reader :tag_name

      def property(name)
        @properties[name]
      end

      def set_tag(name)
        @tag_name = name
      end

      def set_property(name, value)
        @properties ||= {}
        @properties[name] = value
      end
    end
  end

  let(:client) { instance_double(Chromate::Client) }
  subject(:element) { test_class.new(client) }

  describe '#select?' do
    context 'when element is a select' do
      before { element.set_tag('select') }

      it 'returns true' do
        expect(element.select?).to be true
      end
    end

    context 'when element is not a select' do
      before { element.set_tag('div') }

      it 'returns false' do
        expect(element.select?).to be false
      end
    end
  end

  describe '#option?' do
    context 'when element is an option' do
      before { element.set_tag('option') }

      it 'returns true' do
        expect(element.option?).to be true
      end
    end

    context 'when element is not an option' do
      before { element.set_tag('div') }

      it 'returns false' do
        expect(element.option?).to be false
      end
    end
  end

  describe '#radio?' do
    context 'when element is a radio input' do
      before do
        element.set_tag('input')
        element.set_property('type', 'radio')
      end

      it 'returns true' do
        expect(element.radio?).to be true
      end
    end

    context 'when element is not a radio input' do
      before do
        element.set_tag('input')
        element.set_property('type', 'text')
      end

      it 'returns false' do
        expect(element.radio?).to be false
      end
    end
  end

  describe '#checkbox?' do
    context 'when element is a checkbox input' do
      before do
        element.set_tag('input')
        element.set_property('type', 'checkbox')
      end

      it 'returns true' do
        expect(element.checkbox?).to be true
      end
    end

    context 'when element is not a checkbox input' do
      before do
        element.set_tag('input')
        element.set_property('type', 'text')
      end

      it 'returns false' do
        expect(element.checkbox?).to be false
      end
    end
  end

  describe '#base?' do
    context 'when element is a basic element' do
      before { element.set_tag('div') }

      it 'returns true' do
        expect(element.base?).to be true
      end
    end

    %w[select option].each do |tag|
      context "when element is a #{tag}" do
        before { element.set_tag(tag) }

        it 'returns false' do
          expect(element.base?).to be false
        end
      end
    end

    [%w[radio radio], %w[checkbox checkbox]].each do |type, name|
      context "when element is a #{name} input" do
        before do
          element.set_tag('input')
          element.set_property('type', type)
        end

        it 'returns false' do
          expect(element.base?).to be false
        end
      end
    end
  end
end
