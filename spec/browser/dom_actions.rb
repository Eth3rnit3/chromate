# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Dom actions' do
  let(:browser) { Chromate::Browser.new(headless: true) }

  before(:each) do
    browser.start
    @url = server_urls['dom_actions']
    browser.navigate_to(@url)
    browser.refresh
  end

  after(:each) do
    browser.stop
  end

  it 'clicks a button' do
    button = browser.find_element('#click-button')
    button.click

    result = browser.find_element('#click-result')
    expect(result.text).to eq('Button clicked!')
  end

  it 'hovers over an element' do
    hover_box = browser.find_element('#hover-box')

    hover_box.hover

    expect(hover_box.attributes['class']).to include('hover-highlight')
  end

  it 'types text into an input' do
    input = browser.find_element('#input-text')
    input.type('Testing Chromate')

    result = browser.find_element('#input-result')
    expect(result.text).to eq('No input yet')

    input.press_enter
    expect(result.text).to eq('Input submitted: Testing Chromate')
  end

  it 'presses the Enter key' do
    input = browser.find_element('#input-text')
    input.type('Pressing Enter Test')
    input.press_enter

    result = browser.find_element('#input-result')
    expect(result.text).to eq('Input submitted: Pressing Enter Test')
  end

  it 'selects an option from a dropdown' do
    browser.select_option('#test-select', 'option2')

    result = browser.find_element('#select-result')
    expect(result.text).to eq('Selected option: option2')
  end

  it 'evaluates a JavaScript expression' do
    result = browser.evaluate_script('document.title')
    expect(result).to eq('Chromate Actions Test Page')
  end
end
